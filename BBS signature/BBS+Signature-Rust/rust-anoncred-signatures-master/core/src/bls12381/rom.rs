/*
   Copyright (C) 2019 MIRACL UK Ltd.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.


    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

     https://www.gnu.org/licenses/agpl-3.0.en.html

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   You can be released from the requirements of the license by purchasing     
   a commercial license. Buying such a license is mandatory as soon as you
   develop commercial activities involving the MIRACL Core Crypto SDK
   without disclosing the source code of your own applications, or shipping
   the MIRACL Core Crypto SDK with a closed source product.     
*/

use crate::arch::Chunk;
use crate::bls12381::big::NLEN;

// Base Bits= 58
// bls12381 Modulus

pub const MODULUS: [Chunk; NLEN] = [
    0x1FEFFFFFFFFAAAB,
    0x2FFFFAC54FFFFEE,
    0x12A0F6B0F6241EA,
    0x213CE144AFD9CC3,
    0x2434BACD764774B,
    0x25FF9A692C6E9ED,
    0x1A0111EA3,
];
pub const ROI: [Chunk; NLEN] = [
    0x1FEFFFFFFFFAAAA,
    0x2FFFFAC54FFFFEE,
    0x12A0F6B0F6241EA,
    0x213CE144AFD9CC3,
    0x2434BACD764774B,
    0x25FF9A692C6E9ED,
    0x1A0111EA3,
];
pub const R2MODP: [Chunk; NLEN] = [
    0x20639A1D5BEF7AE,
    0x1244C6462DD93E8,
    0x22D09B54E6E2CD2,
    0x111C4B63170E5DB,
    0x38A6DE8FB366399,
    0x4F16CFED1F9CBC,
    0x19EA66A2B,
];
pub const MCONST: Chunk = 0x1F3FFFCFFFCFFFD;
pub const FRA: [Chunk; NLEN] = [
    0x10775ED92235FB8,
    0x3A94F58F9E04F63,
    0x3D784BAB9C4F67,
    0x3F4F2F57D3DEC91,
    0x202C0D1F0FD603,
    0xAEC199F08C6FAD,
    0x1904D3BF0,
];
pub const FRB: [Chunk; NLEN] = [
    0xF78A126DDC4AF3,
    0x356B0535B1FB08B,
    0xEC971F63C5F282,
    0x21EDB1ECDBFB032,
    0x2231F9FB854A147,
    0x1B1380CA23A7A40,
    0xFC3E2B3,
];

pub const CURVE_COF_I: isize = 0;
pub const CURVE_A: isize = 0;
pub const CURVE_B_I: isize = 4;
pub const CURVE_B: [Chunk; NLEN] = [0x4, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0];
pub const CURVE_ORDER: [Chunk; NLEN] = [
    0x3FFFFFF00000001,
    0x36900BFFF96FFBF,
    0x180809A1D80553B,
    0x14CA675F520CCE7,
    0x73EDA7,
    0x0,
    0x0,
];
pub const CURVE_GX: [Chunk; NLEN] = [
    0x33AF00ADB22C6BB,
    0x17A0FFE5E86BBFE,
    0x3A3F171BAC586C5,
    0x13E5DD2E4168538,
    0x4FA9AC0FC3688C,
    0x65F5E509A558E3,
    0x17F1D3A73,
];
pub const CURVE_GY: [Chunk; NLEN] = [
    0xAA232946C5E7E1,
    0x331D128A222B903,
    0x18CB2C04B3EDD03,
    0x25757402BD8036C,
    0x1741D8AE4FCF5E0,
    0xEAA83C68278C3B,
    0x8B3F481E,
];

pub const CURVE_BNX: [Chunk; NLEN] = [0x201000000010000, 0x34, 0x0, 0x0, 0x0, 0x0, 0x0];
pub const CURVE_COF: [Chunk; NLEN] = [0x201000000010001,0x34,0x0, 0x0, 0x0, 0x0, 0x0];
pub const CURVE_CRU: [Chunk; NLEN] = [
    0x201FFFFFFFEFFFE,
    0x1F604D88280008B,
    0x293BE6F89688DE1,
    0x1DA83DDFAB76CE,
    0x3DF76CE51BA69C6,
    0x17C659CB,
    0x0,
];

pub const CURVE_PXA: [Chunk; NLEN] = [
    0x8056C8C121BDB8,
    0x300C9AA016EFBF5,
    0xB647AE3D1770BA,
    0x353E900EC0AD144,
    0x32DC51051C6E47A,
    0x23C2A449820149,
    0x24AA2B2F,
];
pub const CURVE_PXB: [Chunk; NLEN] = [
    0x1AC7D055D042B7E,
    0x33C4484E51755F9,
    0x21BBDC7F5049334,
    0x3426482D86AD769,
    0x88274F65596BD0,
    0x9C67D81F6B34E8,
    0x13E02B605,
];
pub const CURVE_PYA: [Chunk; NLEN] = [
    0x193548608B82801,
    0x2B2730EEB28A278,
    0x1A695160D12C923,
    0x2AA32F74E9DB50A,
    0x2DA2E351AADFD9B,
    0x9F5B8463327371,
    0xCE5D5277,
];
pub const CURVE_PYB: [Chunk; NLEN] = [
    0x2A9075FF05F79BE,
    0x1C349D73B07686A,
    0x12AB572E99AB3F3,
    0x1FA169D8EBC99D2,
    0x2BC28B99CB3E28,
    0x3A9CD330CAB34AC,
    0x606C4A02,
];
pub const CURVE_W: [[Chunk; NLEN]; 2] = [
    [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
];
pub const CURVE_SB: [[[Chunk; NLEN]; 2]; 2] = [
    [
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    ],
    [
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    ],
];
pub const CURVE_WB: [[Chunk; NLEN]; 4] = [
    [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
];
pub const CURVE_BB: [[[Chunk; NLEN]; 4]; 4] = [
    [
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    ],
    [
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    ],
    [
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    ],
    [
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0],
    ],
];

pub const USE_GLV: bool = true;
pub const USE_GS_G2: bool = true;
pub const USE_GS_GT: bool = true;
pub const GT_STRONG: bool = false;
