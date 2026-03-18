package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

public class VotParameterSet {

    public VotParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter(0);
        this.alphaBike = parameterReader.getDoubleParameter(1);
        this.alphaCarDriver = parameterReader.getDoubleParameter(2);
        this.alphaBus = parameterReader.getDoubleParameter(3);
        this.alphaTrain = parameterReader.getDoubleParameter(4);
        this.betaTimeWalk = parameterReader.getDoubleParameter(5);
        this.betaTimeBike = parameterReader.getDoubleParameter(6);
        this.betaTimeCarDriver = parameterReader.getDoubleParameter(7);
        this.betaTimeBus = parameterReader.getDoubleParameter(8);
        this.betaTimeTrain = parameterReader.getDoubleParameter(9);
        this.betaTimeWalkTransport = parameterReader.getDoubleParameter(10);
        this.betaChangesTransport = parameterReader.getDoubleParameter(11);
        this.betaCostLow = parameterReader.getDoubleParameter(12);
        this.betaCostMed = parameterReader.getDoubleParameter(13);
        this.betaCostHigh = parameterReader.getDoubleParameter(14);
        this.votCommuteWalk = parameterReader.getDoubleParameter(15);
        this.votCommuteBike = parameterReader.getDoubleParameter(16);
        this.votCommuteCar = parameterReader.getDoubleParameter(17);
        this.votCommuteBus = parameterReader.getDoubleParameter(18);
        this.votCommuteTrain = parameterReader.getDoubleParameter(19);
        this.votOtherWalk = parameterReader.getDoubleParameter(20);
        this.votOtherBike = parameterReader.getDoubleParameter(21);
        this.votOtherCar = parameterReader.getDoubleParameter(22);
        this.votOtherBus = parameterReader.getDoubleParameter(23);
        this.votOtherTrain = parameterReader.getDoubleParameter(24);
        this.carCostKm = parameterReader.getDoubleParameter(25);
        this.ptCostKm = parameterReader.getDoubleParameter(26);
        this.ptBaseCost = parameterReader.getDoubleParameter(27);
    }
    private final double alphaWalk;
    public double getAlphaWalk() { return this.alphaWalk; }
    private final double alphaBike;
    public double getAlphaBike() { return this.alphaBike; }
    private final double alphaCarDriver;
    public double getAlphaCarDriver() { return this.alphaCarDriver; }
    private final double alphaBus;
    public double getAlphaBus() { return this.alphaBus; }
    private final double alphaTrain;
    public double getAlphaTrain() { return this.alphaTrain; }
    private final double betaTimeWalk;
    public double getBetaTimeWalk() { return this.betaTimeWalk; }
    private final double betaTimeBike;
    public double getBetaTimeBike() { return this.betaTimeBike; }
    private final double betaTimeCarDriver;
    public double getBetaTimeCarDriver() { return this.betaTimeCarDriver; }
    private final double betaTimeBus;
    public double getBetaTimeBus() { return this.betaTimeBus; }
    private final double betaTimeTrain;
    public double getBetaTimeTrain() { return this.betaTimeTrain; }
    private final double betaTimeWalkTransport;
    public double getBetaTimeWalkTransport() { return this.betaTimeWalkTransport; }
    private final double betaChangesTransport;
    public double getBetaChangesTransport() { return this.betaChangesTransport; }
    private final double betaCostLow;
    public double getBetaCostLow() { return this.betaCostLow; }
    private final double betaCostMed;
    public double getBetaCostMed() { return this.betaCostMed; }
    private final double betaCostHigh;
    public double getBetaCostHigh() { return this.betaCostHigh; }
    private final double votCommuteWalk;
    public double getVotCommuteWalk() { return this.votCommuteWalk; }
    private final double votCommuteBike;
    public double getVotCommuteBike() { return this.votCommuteBike; }
    private final double votCommuteCar;
    public double getVotCommuteCar() { return this.votCommuteCar; }
    private final double votCommuteBus;
    public double getVotCommuteBus() { return this.votCommuteBus; }
    private final double votCommuteTrain;
    public double getVotCommuteTrain() { return this.votCommuteTrain; }
    private final double votOtherWalk;
    public double getVotOtherWalk() { return this.votOtherWalk; }
    private final double votOtherBike;
    public double getVotOtherBike() { return this.votOtherBike; }
    private final double votOtherCar;
    public double getVotOtherCar() { return this.votOtherCar; }
    private final double votOtherBus;
    public double getVotOtherBus() { return this.votOtherBus; }
    private final double votOtherTrain;
    public double getVotOtherTrain() { return this.votOtherTrain; }
    public final double carCostKm;
    public double getCarCostKm(){return this.carCostKm;}
    public final double ptCostKm;
    public double getPtCostKm(){return this.ptCostKm;}
    public final double ptBaseCost;
    public double getPtBaseCost(){return this.ptBaseCost;}
}
