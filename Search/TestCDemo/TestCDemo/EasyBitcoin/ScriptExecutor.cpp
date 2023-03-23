// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include <stdexcept>
#include <algorithm>

#include "Conversions.h"
#include "BtcPublicKey.h"
#include "Transaction.h"
#include "ScriptExecutor.h"
#include "Constants.h"

ScriptExecutor::ScriptExecutor(const Transaction &t, size_t inputNumber)
{
    this->script = t.inputs[inputNumber].script + t.inputs[inputNumber].prevOutScript;
    this->position = 0;
    this->t = t;
    this->inputNumber = inputNumber;
    this->state = RUNNING;
}

std::vector<ByteArray> ScriptExecutor::getStack()
{
    return stack;
}

bool ScriptExecutor::run(bool onlyOneStep)
{
    if (state != RUNNING)
        return false;

    do
    {
        if (position >= script.size())
        {
            if(stack.empty())
            {
                state = INVALID;
            }
            else if(Conversions::toScriptVarInt(stack[0]) == 0)
            {
                state = INVALID;
            }
            else
            {
                state = VALID;
            }

            return false;
        }

        Byte instruction = script[position];

        if ((instruction >= OP_PUSH_BEGIN) && (instruction <= OP_PUSH_END))
        {
            if (position + instruction < script.size())
            {
                stack.push_back(script.getSection(position + 1, instruction));
                position += instruction + 1;
            }
            else
            {
                throw std::runtime_error("unexpected end of script (2)");
            }
            continue;
        }

        if (instruction >= OP_2 && instruction <= OP_16)
        {
            stack.push_back(ByteArray() + (instruction - 80));
            position++;
            continue;
        }

        switch(instruction)
        {
            case OP_FALSE:
            {
                stack.push_back(Byte());
                position += 1;
                break;
            }


            case OP_PUSHDATA1:
            {
                if (position + 1 < script.size())
                {
                    ByteArray::size_type len = script[position + 1];
                    if (position + 1 + len < script.size())
                    {
                        ByteArray sTemp;
                        sTemp.insert(sTemp.end(), script.begin() + (position + 2),
                                     script.begin() + (position + len + 1));
                        stack.push_back(sTemp);
                        position += len + 2;
                    }
                    else
                    {
                        throw std::runtime_error("unexpected end of script (2)");
                    }
                }
                else
                {
                    throw std::runtime_error("unexpected end of script (1)");
                }
                break;
            }


            case OP_PUSHDATA2:
            {
                if (position + 2 < script.size())
                {
                    ByteArray::size_type len = script.getSection(position + 1, 2).toUInt16();
                    if (position + 2 + len < script.size())
                    {
                        ByteArray sTemp;
                        sTemp.insert(sTemp.end(), script.begin() + (position + 2),
                                     script.begin() + (position + len + 1));
                        stack.push_back(sTemp);
                        position += len + 3;
                    }
                    else
                    {
                        throw std::runtime_error("unexpected end of script (2)");
                    }
                }
                else
                {
                    throw std::runtime_error("unexpected end of script (1)");
                }
                break;
            }


            case OP_PUSHDATA4:
            {
                if (position + 4 < script.size())
                {
                    ByteArray::size_type len = script.getSection(position + 1, 4).toUInt16();
                    if (position + 4 + len < script.size())
                    {
                        ByteArray sTemp;
                        sTemp.insert(sTemp.end(), script.begin() + (position + 4),
                                     script.begin() + (position + len + 1));
                        stack.push_back(sTemp);
                        position += len + 5;
                    }
                    else
                    {
                        throw std::runtime_error("unexpected end of script (2)");
                    }
                }
                else
                {
                    throw std::runtime_error("unexpected end of script (1)");
                }
                break;
            }


            case OP_1NEGATE:
            {
                stack.push_back(ByteArray() + 0x81); //push -1
                position++;
                break;
            }


            case OP_TRUE:
            {
                stack.push_back(ByteArray() + 1);
                position++;
                break;
            }


            case OP_NOP:
            {
                position++;
                break;
            }


            case OP_IF:
            {
                if ((stack.back().size() == 0 || stack.back()[0] == 0x80) && stack.back().size() <= 1)
                {
                    ByteArray::size_type next = position;

                    try
                    {
                        next = findAfter(OP_ENDIF, position);
                    }
                    catch (std::exception e)
                    {
                    }

                    try
                    {
                        ByteArray::size_type nextElse = findAfter(OP_ENDIF, position);
                        if (next > nextElse)
                        {
                            next = nextElse;
                        }
                    }
                    catch (std::exception e)
                    {
                    }

                    if (next == position)
                    {
                        throw std::runtime_error("unexpected end of script (3)");
                    }

                    position = next + 1;
                }
                else
                {
                    position += 1;
                }
                stack.pop_back();
                break;
            }


            case OP_NOTIF:
            {
                if ((stack.back().size() == 0 || stack.back()[0] == 0x80) && stack.back().size() <= 1)
                {
                    position += 1;
                }
                else
                {
                    ByteArray::size_type next = position;

                    try
                    {
                        next = findAfter(OP_ENDIF, position);
                    }
                    catch (std::exception e)
                    {
                    }

                    try
                    {
                        ByteArray::size_type nextElse = findAfter(OP_ENDIF, position);
                        if (next > nextElse)
                        {
                            next = nextElse;
                        }
                    }
                    catch (std::exception e)
                    {
                    }

                    if (next == position)
                    {
                        throw std::runtime_error("unexpected end of script (3)");
                    }

                    position = next + 1;
                }
                stack.pop_back();
                break;
            }


            case OP_ELSE:
            {
                ByteArray::size_type next = position;

                try
                {
                    next = findAfter(OP_ENDIF, position);
                }
                catch (std::exception e)
                {
                }

                if (next == position)
                {
                    throw std::runtime_error("unexpected end of script (3)");
                }

                position = next + 1;
                break;
            }


            case OP_ENDIF:
            {
                position += 1;
                break;
            }


            case OP_VERIFY:
            {
                if (stack.empty())
                    throw std::runtime_error("nothing to evaluate");

                int64_t val = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                if (val == 0)
                {
                    state = INVALID;
                    stack.push_back(ByteArray());
                }

                break;
            }


            case OP_RETURN:
            {
                state = INVALID;
                position += 1;
                break;
            }


            case OP_TOALTSTACK:
            {
                altStack.push_back(stack.back());
                stack.pop_back();
                position += 1;
                break;
            }


            case OP_FROMALTSTACK:
            {
                stack.push_back(altStack.back());
                altStack.pop_back();
                position += 1;
                break;
            }


            case OP_IFDUP:
            {
                if (!((stack.back().size() == 0 || stack.back()[0] == 0x80) && stack.back().size() <= 1))
                {
                    stack.push_back(stack.back());
                }
                position += 1;
                break;
            }


            case OP_DEPTH:
            {
                stack.push_back(Conversions::fromVarInt(stack.size()));
                position += 1;
                break;
            }


            case OP_DROP:
            {
                stack.pop_back();
                position += 1;
                break;
            }


            case OP_DUP:
            {
                if (stack.size() >= 2)
                {
                    stack.push_back(stack.back());
                }
                else
                {
                    throw std::runtime_error("Error: can't remove second stack item, stack too small.");
                }
                position += 1;
                break;
            }


            case OP_OVER:
            {
                if (stack.size() >= 2)
                {
                    stack.push_back(*(stack.begin() + 1));
                }
                else
                {
                    throw std::runtime_error("Error: can't copy second stack item, stack too small.");
                }
                position += 1;
                break;
            }


            case OP_PICK:
            {
                if (stack.size() == 0)
                    throw std::runtime_error("Error: no item on stack, can't pick one");

                int64_t pickVal = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if ((pickVal >= stack.size()) || (pickVal < 0))
                    throw std::runtime_error("Error: can't pick item from stack, out of bounds");

                ByteArray ptmp = *(stack.rbegin() + pickVal);

                stack.push_back(ptmp);

                position += 1;
                break;
            }


            case OP_ROLL:
            {
                if (stack.size() == 0)
                    throw std::runtime_error("Error: no item on stack, can't roll one");

                int64_t rollVal = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if ((rollVal >= stack.size()) || (rollVal < 0))
                    throw std::runtime_error("Error: can't roll item from stack, out of bounds");

                ByteArray rtmp = *(stack.rbegin() + rollVal);
                stack.erase(stack.begin() + (stack.size() - (rollVal + 1)));

                stack.push_back(rtmp);

                position += 1;
                break;
            }


            case OP_ROT:
            {
                if (stack.size() < 3)
                    throw std::runtime_error("Error: less than three items on stack, can't rotate");

                stack.push_back(*(stack.rbegin() + 2));
                stack.erase(stack.begin() + (stack.size() - 3));

                position += 1;
                break;
            }


            case OP_SWAP:
            {
                if (stack.size() < 2)
                    throw std::runtime_error("Error: can't swap, less than 2 items on stack");

                std::iter_swap(stack.begin() + (stack.size() - 1), stack.begin() + (stack.size() - 2));

                position += 1;
                break;
            }


            case OP_TUCK:
            {
                if (stack.size() < 2)
                    throw std::runtime_error("Error: can't tuck, less than 2 items on stack");

                stack.insert(stack.begin() + (stack.size() - 3), stack.back());

                position += 1;
                break;
            }


            case OP_2DROP:
            {
                if (stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't drop two items");

                stack.erase(stack.begin() + (stack.size() - 2), stack.begin() + (stack.size() - 1));

                position += 1;
                break;
            }


            case OP_2DUP:
            {
                if (stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't 2dup");

                stack.insert(stack.end(), stack.begin() + (stack.size() - 2), stack.begin() + (stack.size() - 1));

                position += 1;
                break;
            }


            case OP_3DUP:
            {
                if (stack.size() < 3)
                    throw std::runtime_error("Error: less than 2 items on stack, can't 3dup");

                stack.insert(stack.end(), stack.begin() + (stack.size() - 3), stack.begin() + (stack.size() - 1));

                position += 1;
                break;
            }


            case OP_2OVER:
            {
                if (stack.size() < 4)
                    throw std::runtime_error("Error: less than 4 items on stack, can't 2over");

                stack.insert(stack.end(), stack.begin() + (stack.size() - 5), stack.begin() + (stack.size() - 3));

                position += 1;
                break;
            }


            case OP_2ROT:
            {
                if (stack.size() < 6)
                    throw std::runtime_error("Error: less than 6 items on stack, can't 2rot");

                stack.insert(stack.end(), stack.begin() + (stack.size() - 7), stack.begin() + (stack.size() - 5));
                stack.erase(stack.begin() + (stack.size() - 9), stack.begin() + (stack.size() - 7));

                position += 1;
                break;
            }


            case OP_2SWAP:
            {
                if (stack.size() < 4)
                    throw std::runtime_error("Error: less than 4 items on stack, can't 2swap");

                stack.insert(stack.end(), stack.begin() + (stack.size() - 5), stack.begin() + (stack.size() - 3));
                stack.erase(stack.begin() + (stack.size() - 7), stack.begin() + (stack.size() - 5));

                position += 1;
                break;
            }


            case OP_SIZE:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: cant push size of top item, no item on stack");

                stack.push_back(Conversions::fromScriptVarInt(stack.back().size()));
                position += 1;
                break;
            }


            case OP_EQUAL:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: can't check if equal, less than 2 items on stack");

                ByteArray in1 = stack.back();
                stack.pop_back();
                ByteArray in2 = stack.back();
                stack.pop_back();

                if (in1 != in2)
                {
                    stack.push_back(ByteArray());
                }
                else
                {
                    stack.push_back(ByteArray() + 1);
                }
                break;
            }


            case OP_EQUALVERIFY:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: can't check if equal, less than 2 items on stack");

                ByteArray in1 = stack.back();
                stack.pop_back();
                ByteArray in2 = stack.back();
                stack.pop_back();

                if (in1 != in2)
                {
                    state = INVALID;
                }

                position += 1;
                break;
            }


            case OP_1ADD:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: no item on stack, can't add 1");

                int64_t in = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                stack.push_back(Conversions::fromScriptVarInt(in + 1));
                break;
            }


            case OP_1SUB:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: no item on stack, can't subtract 1");

                int64_t in = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                stack.push_back(Conversions::fromScriptVarInt(in - 1));
                break;
            }


            case OP_NEGATE:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: no item on stack, can't negate");

                int64_t in = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                stack.push_back(Conversions::fromScriptVarInt(-in));
                break;
            }


            case OP_ABS:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: no item on stack, can't do abs");

                int64_t in = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in < 0)
                    in *= -1;

                stack.push_back(Conversions::fromScriptVarInt(in));
                break;
            }


            case OP_NOT:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: no item on stack, can't do not");

                int64_t in = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                if(in == 0)
                    stack.push_back(ByteArray() + 1);
                else
                    stack.push_back(ByteArray());
                break;
            }


            case OP_0NOTEQUAL:
            {
                if(stack.empty())
                    throw std::runtime_error("Error: no item on stack, can't execute OP_0NOTEQUAL");

                if(Conversions::toScriptVarInt(stack.back()) != 0)
                {
                    stack.back() = Conversions::fromScriptVarInt(1);
                }
                else
                {
                    stack.back() = Conversions::fromScriptVarInt(0);
                }
            }


            case OP_ADD:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't add");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                stack.push_back(Conversions::fromScriptVarInt(in1 + in2));
                break;
            }


            case OP_SUB:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't subtract");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                stack.push_back(Conversions::fromScriptVarInt(in1 - in2));
                break;
            }


            case OP_BOOLAND:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't execute OP_BOOLAND");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if((in1 != 0) && (in2 != 0))
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_BOOLOR:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't execute OP_BOOLOR");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if((in1 != 0) || (in2 != 0))
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_NUMEQUAL:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (numequal)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 == in2)
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }

            case OP_NUMEQUALVERIFY:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (numequalverify)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 != in2)
                {
                    state = INVALID;
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_NUMNOTEQUAL:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (numnotequal)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 != in2)
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_LESSTHAN:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (lessthan)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 > in2)
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_GREATERTHAN:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (greaterthan)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 < in2)
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_LESSTHANOREQUAL:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (lessorequal)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 >= in2)
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_GREATERTHANOREQUAL:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (greaterorequal)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if(in1 <= in2)
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_MIN:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (min)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                stack.push_back(Conversions::fromScriptVarInt(in1 < in2 ? in1 : in2));
                break;
            }


            case OP_MAX:
            {
                if(stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't compare (max)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                stack.push_back(Conversions::fromScriptVarInt(in1 > in2 ? in1 : in2));
                break;
            }


            case OP_WITHIN:
            {
                if(stack.size() < 3)
                    throw std::runtime_error("Error: less than 3 items on stack, can't compare (within)");

                int64_t in1 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in2 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();
                int64_t in3 = Conversions::toScriptVarInt(stack.back());
                stack.pop_back();

                if((in3 >= in2) && (in3 < in1))
                {
                    stack.push_back(ByteArray() + 1);
                }
                else
                {
                    stack.push_back(ByteArray());
                }
                break;
            }


            case OP_CHECKSIG:
            case OP_CHECKSIGVERIFY:
            {
                if (stack.size() < 2)
                    throw std::runtime_error("Error: less than 2 items on stack, can't checksig");

                BtcPublicKey pubKey(stack.back());
                stack.pop_back();
                ByteArray sig = stack.back();
                stack.pop_back();

                if (sig.back() != SIGHASH_ALL)
                    throw std::runtime_error("Error: unsupported hash type (not SIGHASH_ALL)");

                sig.pop_back();

                if (pubKey.checkSig(t.getHashAllForInput(inputNumber), sig))
                {
                    if (instruction == OP_CHECKSIG)
                    {
                        stack.push_back(ByteArray() + 1);
                    }
                }
                else
                {
                    if (instruction == OP_CHECKSIGVERIFY)
                        state = INVALID;

                    stack.push_back(ByteArray());
                }

                position += 1;
                break;
            }


            case OP_HASH160:
            {
                ByteArray in = stack.back();
                stack.pop_back();
                stack.push_back(in.sha256().ripemd160());

                position += 1;
                break;
            }


            default:
            {
                throw std::runtime_error("Error: unknown OP");
            }
        }
    }
    while (!onlyOneStep);

    return true;
}

ByteArray::size_type ScriptExecutor::getPosition()
{
    return position;
}

ByteArray ScriptExecutor::getScript()
{
    return script;
}

ScriptState ScriptExecutor::getState()
{
    return state;
}

ByteArray::size_type ScriptExecutor::findAfter(Byte term, ByteArray::size_type begin)
{
    if (script.size() < begin)
    {
        throw std::runtime_error("unexpected end of script (findAfter 1)");
    }

    while (script[begin] != term)
    {
        if(     script[begin] == 0x65 ||
                script[begin] == 0x66)
        {
            throw std::runtime_error("Error: OP not permitted");
        }

        begin += 1;
        if (begin >= script.size())
        {
            throw std::runtime_error("unexpected end of script (findAfter 2)");
        }
    }

    return begin;
}