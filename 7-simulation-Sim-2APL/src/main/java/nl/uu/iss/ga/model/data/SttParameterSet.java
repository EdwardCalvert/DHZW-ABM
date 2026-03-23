package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

public class SttParameterSet {
    public SttParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter("alphaWalk");
        this.alphaBike = parameterReader.getDoubleParameter("alphaBike");
        this.alphaCarDriver = parameterReader.getDoubleParameter("alphaCarDriver");
        this.alphaCarPassenger = parameterReader.getDoubleParameter("alphaCarPassenger");
        this.alphaBus = parameterReader.getDoubleParameter("alphaBus");
        this.alphaTrain = parameterReader.getDoubleParameter("alphaTrain");
        this.betaTimeWalk = parameterReader.getDoubleParameter("betaTimeWalk");
        this.betaTimeBike = parameterReader.getDoubleParameter("betaTimeBike");
        this.betaTimeCarDriver = parameterReader.getDoubleParameter("betaTimeCarDriver");
        this.betaTimeCarPassenger = parameterReader.getDoubleParameter("betaTimeCarPassenger");
        this.betaTimeBus = parameterReader.getDoubleParameter("betaTimeBus");
        this.betaTimeTrain = parameterReader.getDoubleParameter("betaTimeTrain");
        this.betaCostCarDriver = parameterReader.getDoubleParameter("betaCostCarDriver");
        this.betaCostCarPassenger = parameterReader.getDoubleParameter("betaCostCarPassenger");
        this.betaCostBus = parameterReader.getDoubleParameter("betaCostBus");
        this.betaCostTrain = parameterReader.getDoubleParameter("betaCostTrain");
        this.betaTimeWalkTransport = parameterReader.getDoubleParameter("betaTimeWalkTransport");
        this.betaChangesTransport = parameterReader.getDoubleParameter("betaChangesTransport");
        this.carCostKm = parameterReader.getDoubleParameter("carCostKm");
        this.ptCostKm = parameterReader.getDoubleParameter("ptCostKm");
        this.ptBaseCost = parameterReader.getDoubleParameter("ptBaseCost");
    }

    private final double alphaWalk;
    public double alphaWalk() { return this.alphaWalk; }
    private final double alphaBike;
    public double alphaBike() { return this.alphaBike; }
    private final double alphaCarDriver;
    public double alphaCarDriver() { return this.alphaCarDriver; }
    private final double alphaCarPassenger;
    public double alphaCarPassenger() { return this.alphaCarPassenger; }
    private final double alphaBus;
    public double alphaBus() { return this.alphaBus; }
    private final double alphaTrain;
    public double alphaTrain() { return this.alphaTrain; }
    private final double betaTimeWalk;
    public double betaTimeWalk() { return this.betaTimeWalk; }
    private final double betaTimeBike;
    public double betaTimeBike() { return this.betaTimeBike; }
    private final double betaTimeCarDriver;
    public double betaTimeCarDriver() { return this.betaTimeCarDriver; }
    private final double betaTimeCarPassenger;
    public double betaTimeCarPassenger() { return this.betaTimeCarPassenger; }
    private final double betaTimeBus;
    public double betaTimeBus() { return this.betaTimeBus; }
    private final double betaTimeTrain;
    public double betaTimeTrain() { return this.betaTimeTrain; }
    private final double betaCostCarDriver;
    public double betaCostCarDriver() { return this.betaCostCarDriver; }
    private final double betaCostCarPassenger;
    public double betaCostCarPassenger() { return this.betaCostCarPassenger; }
    private final double betaCostBus;
    public double betaCostBus() { return this.betaCostBus; }
    private final double betaCostTrain;
    public double betaCostTrain() { return this.betaCostTrain; }
    private final double betaTimeWalkTransport;
    public double betaTimeWalkTransport() { return this.betaTimeWalkTransport; }
    private final double betaChangesTransport;
    public double betaChangesTransport() { return this.betaChangesTransport; }
    public final double carCostKm;
    public double carCostKm(){return this.carCostKm;}
    public final double ptCostKm;
    public double ptCostKm(){return this.ptCostKm;}
    public final double ptBaseCost;
    public double ptBaseCost(){return this.ptBaseCost;}
}
