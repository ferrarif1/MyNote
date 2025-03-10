/**
 * Copyright (c) woodser
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package monero.daemon;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import monero.daemon.model.MoneroBan;
import monero.daemon.model.MoneroBlock;
import monero.daemon.model.MoneroBlockTemplate;
import monero.daemon.model.MoneroDaemonUpdateDownloadResult;
import monero.daemon.model.MoneroKeyImageSpentStatus;
import monero.daemon.model.MoneroOutputDistributionEntry;
import monero.daemon.model.MoneroSubmitTxResult;
import monero.daemon.model.MoneroTx;

/**
 * Abstract default implementation of a Monero daemon.
 */
public abstract class MoneroDaemonDefault implements MoneroDaemon {
  
  @Override
  public MoneroBlockTemplate getBlockTemplate(String walletAddress) {
    return getBlockTemplate(walletAddress, null);
  }
  
  @Override
  public List<MoneroBlock> getBlocksByRangeChunked(Long startHeight, Long endHeight) {
    return getBlocksByRangeChunked(startHeight, endHeight, null);
  }
  
  @Override
  public MoneroTx getTx(String txHash) {
    return getTx(txHash, null);
  }
  
  @Override
  public MoneroTx getTx(String txHash, Boolean prune) {
    List<MoneroTx> txs = getTxs(Arrays.asList(txHash), prune);
    return txs.size() == 0 ? null : txs.get(0);
  }
  
  @Override
  public List<MoneroTx> getTxs(Collection<String> txHashes) {
    return getTxs(txHashes, null);
  }
  
  @Override
  public String getTxHex(String txHash) {
    return getTxHex(txHash, false);
  }
  
  @Override
  public String getTxHex(String txHash, Boolean prune) {
    return getTxHexes(Arrays.asList(txHash), prune).get(0);
  }
  
  @Override
  public List<String> getTxHexes(Collection<String> txHashes) {
    return getTxHexes(txHashes, null);
  }
  
  @Override
  public BigInteger getFeeEstimate() {
    return getFeeEstimate(null);
  }
  
  @Override
  public MoneroSubmitTxResult submitTxHex(String txHex) {
    return submitTxHex(txHex, false);
  }
  
  @Override
  public void relayTxByHash(String txHash) {
    relayTxsByHash(Arrays.asList(txHash));
  }
  
  @Override
  public MoneroKeyImageSpentStatus getKeyImageSpentStatus(String keyImage) {
    return getKeyImageSpentStatuses(Arrays.asList(keyImage)).get(0);
  }
  
  @Override
  public List<MoneroOutputDistributionEntry> getOutputDistribution(Collection<BigInteger> amounts) {
    return getOutputDistribution(amounts, null, null, null);
  }
  
  @Override
  public void setPeerBan(MoneroBan ban) {
    setPeerBans(Arrays.asList(ban));
  }
  
  @Override
  public void submitBlock(String blockBlob) {
    submitBlocks(Arrays.asList(blockBlob));
  }
  
  @Override
  public MoneroDaemonUpdateDownloadResult downloadUpdate() {
    return downloadUpdate(null);
  }
}
