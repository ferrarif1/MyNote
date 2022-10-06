package monero.daemon.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigInteger;

/**
 * Monero daemon info.
 */
public class MoneroDaemonInfo {
  
  private String version;
  private Long numAltBlocks;
  private Long blockSizeLimit;
  private Long blockSizeMedian;
  private Long blockWeightLimit;
  private Long blockWeightMedian;
  private String bootstrapDaemonAddress;
  private BigInteger difficulty;
  private BigInteger cumulativeDifficulty;
  private BigInteger freeSpace;
  private Integer numOfflinePeers;
  private Integer numOnlinePeers;
  private Long height;
  private Long heightWithoutBootstrap;
  private MoneroNetworkType networkType;
  private Boolean isOffline;
  private Integer numIncomingConnections;
  private Integer numOutgoingConnections;
  private Integer numRpcConnections;
  private Long startTimestamp;
  private Long adjustedTimestamp;
  private Long target;
  private Long targetHeight;
  private String topBlockHash;
  private Integer numTxs;
  private Integer numTxsPool;
  private Boolean wasBootstrapEverUsed;
  private Long databaseSize;
  private Boolean updateAvailable;
  private BigInteger credits;
  private Boolean isBusySyncing;
  private Boolean isSynchronized;
  private Boolean isRestricted;
  
  public String getVersion() {
    return version;
  }
  
  public void setVersion(String version) {
    this.version = version;
  }
  
  public Long getNumAltBlocks() {
    return numAltBlocks;
  }
  
  public void setNumAltBlocks(Long numAltBlocks) {
    this.numAltBlocks = numAltBlocks;
  }
  
  public Long getBlockSizeLimit() {
    return blockSizeLimit;
  }
  
  public void setBlockSizeLimit(Long blockSizeLimit) {
    this.blockSizeLimit = blockSizeLimit;
  }
  
  public Long getBlockSizeMedian() {
    return blockSizeMedian;
  }
  
  public void setBlockSizeMedian(Long blockSizeMedian) {
    this.blockSizeMedian = blockSizeMedian;
  }
  
  public Long getBlockWeightLimit() {
    return blockWeightLimit;
  }
  
  public MoneroDaemonInfo setBlockWeightLimit(Long blockWeightLimit) {
    this.blockWeightLimit = blockWeightLimit;
    return this;
  }
  
  public Long getBlockWeightMedian() {
    return blockWeightMedian;
  }
  
  public void setBlockWeightMedian(Long blockWeightMedian) {
    this.blockWeightMedian = blockWeightMedian;
  }
  
  public String getBootstrapDaemonAddress() {
    return bootstrapDaemonAddress;
  }
  
  public void setBootstrapDaemonAddress(String bootstrapDaemonAddress) {
    this.bootstrapDaemonAddress = bootstrapDaemonAddress;
  }
  
  public BigInteger getDifficulty() {
    return difficulty;
  }
  
  public void setDifficulty(BigInteger difficulty) {
    this.difficulty = difficulty;
  }
  
  public BigInteger getCumulativeDifficulty() {
    return cumulativeDifficulty;
  }
  
  public void setCumulativeDifficulty(BigInteger cumulativeDifficulty) {
    this.cumulativeDifficulty = cumulativeDifficulty;
  }
  
  public BigInteger getFreeSpace() {
    return freeSpace;
  }
  
  public void setFreeSpace(BigInteger freeSpace) {
    this.freeSpace = freeSpace;
  }
  
  public Integer getNumOfflinePeers() {
    return numOfflinePeers;
  }
  
  public void setNumOfflinePeers(Integer numOfflinePeers) {
    this.numOfflinePeers = numOfflinePeers;
  }
  
  public Integer getNumOnlinePeers() {
    return numOnlinePeers;
  }
  
  public void setNumOnlinePeers(Integer numOnlinePeers) {
    this.numOnlinePeers = numOnlinePeers;
  }
  
  public Long getHeight() {
    return height;
  }
  
  public void setHeight(Long height) {
    this.height = height;
  }
  
  public Long getHeightWithoutBootstrap() {
    return heightWithoutBootstrap;
  }
  
  public void setHeightWithoutBootstrap(Long heightWithoutBootstrap) {
    this.heightWithoutBootstrap = heightWithoutBootstrap;
  }
  
  public MoneroNetworkType getNetworkType() {
    return networkType;
  }
  
  public void setNetworkType(MoneroNetworkType networkType) {
    this.networkType = networkType;
  }
  
  @JsonProperty("isOffline")
  public Boolean isOffline() {
    return isOffline;
  }
  
  public void setIsOffline(Boolean isOffline) {
    this.isOffline = isOffline;
  }
  
  public Integer getNumIncomingConnections() {
    return numIncomingConnections;
  }
  
  public void setNumIncomingConnections(Integer numIncomingConnections) {
    this.numIncomingConnections = numIncomingConnections;
  }
  
  public Integer getNumOutgoingConnections() {
    return numOutgoingConnections;
  }
  
  public void setNumOutgoingConnections(Integer numOutgoingConnections) {
    this.numOutgoingConnections = numOutgoingConnections;
  }
  
  public Integer getNumRpcConnections() {
    return numRpcConnections;
  }
  
  public void setNumRpcConnections(Integer numRpcConnections) {
    this.numRpcConnections = numRpcConnections;
  }
  
  public Long getStartTimestamp() {
    return startTimestamp;
  }
  
  public void setStartTimestamp(Long startTimestamp) {
    this.startTimestamp = startTimestamp;
  }
  
  public Long getAdjustedTimestamp() {
    return adjustedTimestamp;
  }
  
  public void setAdjustedTimestamp(Long adjustedTimestamp) {
    this.adjustedTimestamp = adjustedTimestamp;
  }
  
  public Long getTarget() {
    return target;
  }
  
  public void setTarget(Long target) {
    this.target = target;
  }
  
  public Long getTargetHeight() {
    return targetHeight;
  }
  
  public void setTargetHeight(Long targetHeight) {
    this.targetHeight = targetHeight;
  }
  
  public String getTopBlockHash() {
    return topBlockHash;
  }
  
  public void setTopBlockHash(String topBlockHash) {
    this.topBlockHash = topBlockHash;
  }
  
  public Integer getNumTxs() {
    return numTxs;
  }
  
  public void setNumTxs(Integer numTxs) {
    this.numTxs = numTxs;
  }
  
  public Integer getNumTxsPool() {
    return numTxsPool;
  }
  
  public void setNumTxsPool(Integer numTxsPool) {
    this.numTxsPool = numTxsPool;
  }
  
  public Boolean getWasBootstrapEverUsed() {
    return wasBootstrapEverUsed;
  }
  
  public void setWasBootstrapEverUsed(Boolean wasBootstrapEverUsed) {
    this.wasBootstrapEverUsed = wasBootstrapEverUsed;
  }
  
  public Long getDatabaseSize() {
    return databaseSize;
  }
  
  public void setDatabaseSize(Long databaseSize) {
    this.databaseSize = databaseSize;
  }
  
  public Boolean getUpdateAvailable() {
    return updateAvailable;
  }
  
  public void setUpdateAvailable(Boolean updateAvailable) {
    this.updateAvailable = updateAvailable;
  }

  public BigInteger getCredits() {
    return credits;
  }

  public void setCredits(BigInteger credits) {
    this.credits = credits;
  }
  
  @JsonProperty("isBusySyncing")
  public Boolean isBusySyncing() {
    return isBusySyncing;
  }
  
  public void setIsBusySyncing(Boolean isBusySyncing) {
    this.isBusySyncing = isBusySyncing;
  }
  
  @JsonProperty("isSynchronized")
  public Boolean isSynchronized() {
    return isSynchronized;
  }
  
  public void setIsSynchronized(Boolean isSynchronized) {
    this.isSynchronized = isSynchronized;
  }
  
  @JsonProperty("isRestricted")
  public Boolean isRestricted() {
    return isRestricted;
  }
  
  public void setIsRestricted(Boolean isRestricted) {
    this.isRestricted = isRestricted;
  }
}
