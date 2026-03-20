package main.java.nl.uu.iss.ga.model.data.dictionary;

import java.util.HashMap;

public class ModeAttributes {
    HashMap<TransportMode, Double> travelTimes;
    HashMap<TransportMode, Double> travelDistances;

    public int nChangesBus = 0;
    public int nChangesTrain = 0;
    public double walkTimeBus = 0;
    public double walkTimeTrain = 0;
    public double busTimeTrain = 0;
    public double busDistanceTrain = 0;

    public ModeAttributes(){

        travelTimes = new HashMap<>();
        travelDistances = new HashMap<>();
    }

    public void setTime(TransportMode mode, Double value){
        this.travelTimes.put(mode, value);
    }
    public  Double getTime(TransportMode mode){
        return this.travelTimes.get(mode);
    }

    public void setDistance(TransportMode mode, Double value){
        this.travelDistances.put(mode, value);
    }
    public Double getDistance(TransportMode mode){
        return travelTimes.get(mode);
    }
    public boolean modePresent(TransportMode mode){
        return  travelTimes.containsKey(mode) && travelDistances.containsKey(mode);
    }

    public boolean isEmpty(){
        return travelTimes.isEmpty() && travelDistances.isEmpty();
    }
}
