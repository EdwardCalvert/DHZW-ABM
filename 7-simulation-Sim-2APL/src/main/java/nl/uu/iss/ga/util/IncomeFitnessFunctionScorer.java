package main.java.nl.uu.iss.ga.util;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.data.dictionary.util.StringCodeTypeInterface;
import main.java.nl.uu.iss.ga.simulation.EnvironmentInterface;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

public class IncomeFitnessFunctionScorer {
    private static final Logger LOGGER = Logger.getLogger(EnvironmentInterface.class.getName());
    private Double[][] simulatedPercentages;
    private Double score;
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
                double simulatedPercent =  incomeModeMap[incomeThird.ordinal()][transportMode.ordinal()].get()/incomeThirdSum[incomeThird.ordinal()];
                percentageIncomeModeMap[incomeThird.ordinal()][transportMode.ordinal()] = simulatedPercent;
                score+=   Math.pow(((simulatedPercent-expectedProportions.get(incomeThird).get(transportMode))*100),2);
            }
        }
        this.simulatedPercentages = percentageIncomeModeMap;
        this.expectedPercentages = expectedProportions;

        double finalScore = Math.sqrt(score/(TransportMode.values().length * IncomeThirds.values().length) ) ;
        this.score = finalScore;
        return finalScore;
    }

    private double calculateRow(double expectedPercent, double simulatedPercent){
        return Math.abs(simulatedPercent - expectedPercent) * expectedPercent;
    }

    public void saveScore(File output_dir) throws IOException {
        if(score == null){
            throw new RuntimeException("Scoring must take place first");
        }
        Files.write(Paths.get(output_dir.toString(), "income_score.txt"), this.score.toString().getBytes());
    }
    public void saveIncome(File output_dir) throws IOException {
        if(expectedPercentages == null|| simulatedPercentages == null){
            throw new RuntimeException("Scoring must take place first");
        }
        CSVWriter writer = new CSVWriter(new FileWriter(new File(output_dir, "income_mode_percent.csv")));

        String[] row = new String[5];
        row[0] = "income_group";
        row[1] = "mode_choice";
        row[2] = "simulated percent";
        row[3] = "expected percent";
        row[4] = "difference";
        Double[][] percentages = this.simulatedPercentages;
        HashMap<IncomeThirds, HashMap<TransportMode, Double>> stuff = this.expectedPercentages;
        writer.writeNext(row);
        for (IncomeThirds incomeGroup : IncomeThirds.values()) {
            row = new String[5];
            row[0] = String.valueOf(incomeGroup);
            for (TransportMode mode : TransportMode.values()) {
                row[1] = String.valueOf(mode);
                Double value = percentages[incomeGroup.ordinal()][mode.ordinal()];
                row[2] = String.valueOf(value*100);
                row[3] = String.valueOf(stuff.get(incomeGroup).get(mode)*100);
                row[4] = String.valueOf((stuff.get(incomeGroup).get(mode) - value)*100);
                writer.writeNext(row);
            }
        }
        writer.close();
    }
}
