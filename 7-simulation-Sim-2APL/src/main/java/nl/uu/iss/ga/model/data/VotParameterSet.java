package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

import java.lang.reflect.Field;

public class VotParameterSet {

    public VotParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter("alphaWalk");
        this.alphaBike = parameterReader.getDoubleParameter("alphaBike");
        this.alphaCarDriver = parameterReader.getDoubleParameter("alphaCarDriver");
        this.alphaCarPassenger = parameterReader.getDoubleParameter("alphaCarPassenger");
        this.alphaBus = parameterReader.getDoubleParameter("alphaBus");
        this.alphaTrain = parameterReader.getDoubleParameter("alphaTrain");
        this.betaChangesTransport = parameterReader.getDoubleParameter("betaChangesTransport");
        betaCost = new double[IncomeThirds.values().length];
        betaCost[IncomeThirds.LOW.ordinal()] = parameterReader.getDoubleParameter("betaCostLow");
        betaCost[IncomeThirds.AVERAGE.ordinal()] = parameterReader.getDoubleParameter("betaCostMed");
        betaCost[IncomeThirds.HIGH.ordinal()] = parameterReader.getDoubleParameter("betaCostHigh");

        vot = new double[TransportMode.values().length][TripPurpose.values().length];
        vot[TransportMode.WALK.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteWalk");
        vot[TransportMode.BIKE.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteBike");
        vot[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteCar");
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteBus");
        vot[TransportMode.TRAIN.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteTrain");

        vot[TransportMode.WALK.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherWalk");
        vot[TransportMode.BIKE.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherBike");
        vot[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherCar");
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherBus");
        vot[TransportMode.TRAIN.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherTrain");


        this.carCostKm = parameterReader.getDoubleParameter("carCostKm");
        this.ptCostKm = parameterReader.getDoubleParameter("ptCostKm");
        this.ptBaseCost = parameterReader.getDoubleParameter("ptBaseCost");
        this.weightWalk = parameterReader.getDoubleParameter("weightWalk");
        this.weightWait = parameterReader.getDoubleParameter("weightWait");
        this.weightFeeder = parameterReader.getDoubleParameter("weightFeeder");

        this.weightVotCosts = parameterReader.getDoubleParameter("weightVotCosts");
        this.weightTangibleCosts = parameterReader.getDoubleParameter("weightTangibleCosts");
        validateParameters();

    }

    public void validateParameters()  {
        for (Field field : this.getClass().getDeclaredFields()) {
            if (field.getType() == Double.class) {
                field.setAccessible(true);
                Object fieldValue = null;
                try{
                    fieldValue = field.get(this);
                }
                catch(IllegalAccessException e){
                    e.printStackTrace();
                }
                if (fieldValue == null) {
                    throw new RuntimeException("Parameter field is missing/null: " + field.getName());
                }
            }
        }
    }
    public final double alphaWalk;
    public final double alphaBike;
    public final double alphaCarDriver;
    public final double alphaCarPassenger;
    public final double alphaBus;
    public final double alphaTrain;
    public final double betaChangesTransport;
    private final double[] betaCost;

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
    public final double carCostKm;
    public final double ptCostKm;
    public final double ptBaseCost;
    public final double weightWalk;
    public final double weightWait;
    public final double weightFeeder;
    public final double weightTangibleCosts;
    public final double weightVotCosts;
}
