package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

public class SttParameterSet {
    public SttParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter(0);
        this.alphaBike = parameterReader.getDoubleParameter(1);
        this.alphaCarDriver = parameterReader.getDoubleParameter(2);
        this.alphaCarPassenger = parameterReader.getDoubleParameter(3);
        this.alphaBus = parameterReader.getDoubleParameter(4);
        this.alphaTrain = parameterReader.getDoubleParameter(5);
        this.betaTimeWalk = parameterReader.getDoubleParameter(6);
        this.betaTimeBike = parameterReader.getDoubleParameter(7);
        this.betaTimeCarDriver = parameterReader.getDoubleParameter(8);
        this.betaTimeCarPassenger = parameterReader.getDoubleParameter(9);
        this.betaTimeBus = parameterReader.getDoubleParameter(10);
        this.betaTimeTrain = parameterReader.getDoubleParameter(11);
        this.betaCostCarDriver = parameterReader.getDoubleParameter(12);
        this.betaCostCarPassenger = parameterReader.getDoubleParameter(13);
        this.betaCostBus = parameterReader.getDoubleParameter(14);
        this.betaCostTrain = parameterReader.getDoubleParameter(15);
        this.betaTimeWalkTransport = parameterReader.getDoubleParameter(16);
        this.betaChangesTransport = parameterReader.getDoubleParameter(17);
        this.carCostKm = parameterReader.getDoubleParameter(18);
        this.ptCostKm = parameterReader.getDoubleParameter(19);
        this.ptBaseCost = parameterReader.getDoubleParameter(20);
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
