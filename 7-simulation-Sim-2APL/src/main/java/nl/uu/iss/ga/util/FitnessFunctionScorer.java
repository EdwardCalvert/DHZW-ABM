package main.java.nl.uu.iss.ga.util;

import com.opencsv.CSVReader;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.data.dictionary.util.StringCodeTypeInterface;
import main.java.nl.uu.iss.ga.simulation.EnvironmentInterface;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FitnessFunctionScorer {
    private static final Logger LOGGER = Logger.getLogger(EnvironmentInterface.class.getName());

    private Double[][] simulatedPercentages;
    private HashMap<IncomeThirds, HashMap<TransportMode, Double>> expectedPercentages;
    public double scoreIncome(AtomicInteger[][] incomeModeMap, File incomeCalibrationSet) throws FileNotFoundException {
        double sum = 0;
        double[] incomeThirdSum = new double[IncomeThirds.values().length];
        // store in map (rather than array), since the CSV may be unordered.
        HashMap<IncomeThirds, HashMap<TransportMode, Double>> expectedProportions = new HashMap<>();

        for(IncomeThirds incomeThird: IncomeThirds.values()){
            HashMap<TransportMode,Double> transportMap = new HashMap<>();
            for(TransportMode transportMode: TransportMode.values()){
                double value = incomeModeMap[incomeThird.ordinal()][transportMode.ordinal()].get();
                sum += value;
                incomeThirdSum[incomeThird.ordinal()] += value;
                transportMap.put(transportMode,0.0);
            }
            expectedProportions.put(incomeThird, transportMap);
        }

        try (CSVReader reader = new CSVReader(new FileReader(incomeCalibrationSet))) {
            reader.skip(1); //skip header
            String[] nextRecord;
            while ((nextRecord = reader.readNext()) != null) {
                TransportMode transportMode = StringCodeTypeInterface.parseAsEnum(TransportMode.class, nextRecord[1]);
                IncomeThirds incomeGroup = StringCodeTypeInterface.parseAsEnum(IncomeThirds.class, nextRecord[0]);
                Double percent = Double.parseDouble(nextRecord[3])/100;
                expectedProportions.get(incomeGroup).put(transportMode, percent);
            }
        }catch (Exception exception){
            LOGGER.log(Level.SEVERE,"Cannot interpret file to score against" , exception);
            throw  new RuntimeException("Score file could not be understood.");
        }
        double score = 0;
        //Convert into percent, and make each income group add to 100%.
        Double[][] percentageIncomeModeMap = new Double[IncomeThirds.values().length][TransportMode.values().length];
        for(IncomeThirds incomeThird: IncomeThirds.values()){
            for(TransportMode transportMode: TransportMode.values()){
                double value =  incomeModeMap[incomeThird.ordinal()][transportMode.ordinal()].get()/incomeThirdSum[incomeThird.ordinal()];
                percentageIncomeModeMap[incomeThird.ordinal()][transportMode.ordinal()] = value;

                score+= calculateRow(expectedProportions.get(incomeThird).get(transportMode), value);
            }
        }
        this.simulatedPercentages = percentageIncomeModeMap;
        this.expectedPercentages = expectedProportions;
        score = Math.pow(score,4);
        return score;
    }

    public Double[][] getSimulatedPercentages() {
        return simulatedPercentages;
    }
    public HashMap<IncomeThirds, HashMap<TransportMode, Double>> getExpectedPercentages(){return expectedPercentages;}

    private double calculateRow(double proportionSimulated, double proportionObserved){
        return Math.abs(proportionSimulated - proportionObserved) * proportionObserved;
    }
}
