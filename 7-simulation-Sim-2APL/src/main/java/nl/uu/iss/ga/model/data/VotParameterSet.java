package main.java.nl.uu.iss.ga.model.data;

import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.reader.ParameterReader;

import java.lang.reflect.Field;

public class VotParameterSet {

    public VotParameterSet(ParameterReader parameterReader){
        this.alphaWalk = parameterReader.getDoubleParameter(0);
        this.alphaBike = parameterReader.getDoubleParameter(1);
        this.alphaCarDriver = parameterReader.getDoubleParameter(2);
        this.alphaCarPassenger = parameterReader.getDoubleParameter(3);
        this.alphaBus = parameterReader.getDoubleParameter(4);
        this.alphaTrain = parameterReader.getDoubleParameter(5);
        this.betaChangesTransport = parameterReader.getDoubleParameter(6);
        betaCost = new double[IncomeThirds.values().length];
        betaCost[IncomeThirds.LOW.ordinal()] = parameterReader.getDoubleParameter(7);
        betaCost[IncomeThirds.AVERAGE.ordinal()] = parameterReader.getDoubleParameter(8);
        betaCost[IncomeThirds.HIGH.ordinal()] = parameterReader.getDoubleParameter(9);

        vot = new double[TransportMode.values().length][TripPurpose.values().length];
        vot[TransportMode.WALK.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(10);
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(11);
        vot[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(12);
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(13);
        vot[TransportMode.TRAIN.ordinal()][TripPurpose.COMMUTE.ordinal()] = parameterReader.getDoubleParameter(14);

        vot[TransportMode.WALK.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(15);
        vot[TransportMode.BIKE.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(16);
        vot[TransportMode.CAR_DRIVER.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(17);
        vot[TransportMode.BUS_TRAM.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(18);
        vot[TransportMode.TRAIN.ordinal()][TripPurpose.OTHER.ordinal()] = parameterReader.getDoubleParameter(19);


        this.carCostKm = parameterReader.getDoubleParameter(20);
        this.ptCostKm = parameterReader.getDoubleParameter(21);
        this.ptBaseCost = parameterReader.getDoubleParameter(22);
        this.weightAccessEgress = parameterReader.getDoubleParameter(23);
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
    public final double weightAccessEgress;
}
