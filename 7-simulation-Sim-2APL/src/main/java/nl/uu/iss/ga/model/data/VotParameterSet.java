package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

public class VotParameterSet {

    public VotParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter(0);
        this.alphaBike = parameterReader.getDoubleParameter(1);
        this.alphaCarDriver = parameterReader.getDoubleParameter(2);
        this.alphaBus = parameterReader.getDoubleParameter(3);
        this.alphaTrain = parameterReader.getDoubleParameter(4);
//        this.betaTimeWalk = parameterReader.getDoubleParameter(5);
//        this.betaTimeBike = parameterReader.getDoubleParameter(6);
//        this.betaTimeCarDriver = parameterReader.getDoubleParameter(7);
//        this.betaTimeBus = parameterReader.getDoubleParameter(8);
//        this.betaTimeTrain = parameterReader.getDoubleParameter(9);
//        this.betaTimeWalkTransport = parameterReader.getDoubleParameter(10);
        this.betaChangesTransport = parameterReader.getDoubleParameter(5);
        betaCost = new double[IncomeThirds.values().length];
        betaCost[IncomeThirds.LOW.ordinal()] = parameterReader.getDoubleParameter(6);
        betaCost[IncomeThirds.AVERAGE.ordinal()] = parameterReader.getDoubleParameter(7);
        betaCost[IncomeThirds.HIGH.ordinal()] = parameterReader.getDoubleParameter(7);

        vot = new double[TransportMode.values().length][TripPurpose.values().length];
        vot[TransportMode.WALK.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(9);
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(10);
        vot[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(11);
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(12);
        vot[TransportMode.TRAIN.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(13);

        vot[TransportMode.WALK.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(14);
        vot[TransportMode.BIKE.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(15);
        vot[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(16);
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(17);
        vot[TransportMode.TRAIN.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(18);


        this.carCostKm = parameterReader.getDoubleParameter(19);
        this.ptCostKm = parameterReader.getDoubleParameter(20);
        this.ptBaseCost = parameterReader.getDoubleParameter(21);
        this.weightAccessEgress = parameterReader.getDoubleParameter(22);
    }
    public final double alphaWalk;
    public final double alphaBike;
    public final double alphaCarDriver;
    public final double alphaBus;


    public final double alphaTrain;
//    private final double betaTimeWalk;
//    public double betaTimeWalk() { return this.betaTimeWalk; }
//    private final double betaTimeBike;
//    public double betaTimeBike() { return this.betaTimeBike; }
//    private final double betaTimeCarDriver;
//    public double betaTimeCarDriver() { return this.betaTimeCarDriver; }
//    private final double betaTimeBus;
//    public double betaTimeBus() { return this.betaTimeBus; }
//    private final double betaTimeTrain;
//    public double betaTimeTrain() { return this.betaTimeTrain; }
//    private final double betaTimeWalkTransport;
//    public double betaTimeWalkTransport() { return this.betaTimeWalkTransport; }
    public final double betaChangesTransport;

    private final double[] betaCost;
//    private final double betaCostLow;
//    private final double betaCostMed;
//    private final double betaCostHigh;

    public double betaCost(IncomeThirds income){
        return betaCost[income.ordinal()];
    }
    private final double[][] vot;
    public double vot(TransportMode mode, TripPurpose purpose){
        if (mode == TransportMode.CAR_PASSENGER){
            throw new RuntimeException("Car passenger not supported"); //I know I should sort the enums. oops.
        }
        return vot[mode.ordinal()][purpose.ordinal()];
    }
//    public final double votCommuteWalk;
//    public final double votCommuteBike;
//    public final double votCommuteCar;
//    public final double votCommuteBus;
//    public final double votCommuteTrain;
//    public final double votOtherWalk;
//    public final double votOtherBike;
//    public final double votOtherCar;
//    public final double votOtherBus;
//    public final double votOtherTrain;
    public final double carCostKm;
    public final double ptCostKm;
    public final double ptBaseCost;
    public final double weightAccessEgress;
}
