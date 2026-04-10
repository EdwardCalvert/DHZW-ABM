package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

import java.lang.reflect.Field;

public class SttUnifiedCostParameterSet {
    public SttUnifiedCostParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter("alphaWalk");
        this.alphaBike = parameterReader.getDoubleParameter("alphaBike");
        this.alphaCarDriver = parameterReader.getDoubleParameter("alphaCarDriver");
        this.alphaCarPassenger = parameterReader.getDoubleParameter("alphaCarPassenger");
        this.alphaBus = parameterReader.getDoubleParameter("alphaBus");
        this.alphaTrain = parameterReader.getDoubleParameter("alphaTrain");

        this.betaTimeWalkTransport = parameterReader.getDoubleParameter("betaTimeWalkTransport");
        this.betaChangesTransport = parameterReader.getDoubleParameter("betaChangesTransport");
        this.carCostKm = parameterReader.getDoubleParameter("carCostKm");
        this.ptCostKm = parameterReader.getDoubleParameter("ptCostKm");
        this.ptBaseCost = parameterReader.getDoubleParameter("ptBaseCost");

        betaCost = new double[IncomeThirds.values().length];
        betaCost[IncomeThirds.LOW.ordinal()] = parameterReader.getDoubleParameter("betaCostLow");
        betaCost[IncomeThirds.AVERAGE.ordinal()] = parameterReader.getDoubleParameter("betaCostMed");
        betaCost[IncomeThirds.HIGH.ordinal()] = parameterReader.getDoubleParameter("betaCostHigh");


        betaTime = new double[TransportMode.values().length][TripPurpose.values().length];
        betaTime[TransportMode.WALK.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteWalk");
        betaTime[TransportMode.BIKE.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteBike");
        betaTime[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteCar");
        betaTime[TransportMode.CAR_PASSENGER.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommutePassenger");
        betaTime[TransportMode.BUS_TRAM.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteBus");
        betaTime[TransportMode.TRAIN.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter("votCommuteTrain");

        betaTime[TransportMode.WALK.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherWalk");
        betaTime[TransportMode.BIKE.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherBike");
        betaTime[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherCar");
        betaTime[TransportMode.CAR_PASSENGER.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherPassenger");
        betaTime[TransportMode.BUS_TRAM.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherBus");
        betaTime[TransportMode.TRAIN.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter("votOtherTrain");

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

    private final double[] betaCost;
    public double betaCost(IncomeThirds income){
        return betaCost[income.ordinal()];
    }
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

    private final double[][] betaTime;
    public double betaTime(TransportMode mode, TripPurpose purpose){
        return betaTime[mode.ordinal()][purpose.ordinal()];
    }
}
