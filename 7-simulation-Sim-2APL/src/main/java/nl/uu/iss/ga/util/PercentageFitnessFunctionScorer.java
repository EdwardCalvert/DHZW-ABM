package main.java.nl.uu.iss.ga.util;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.util.StringCodeTypeInterface;
import main.java.nl.uu.iss.ga.simulation.EnvironmentInterface;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PercentageFitnessFunctionScorer {
    private static final Logger LOGGER = Logger.getLogger(EnvironmentInterface.class.getName());

    private Map<TransportMode, Double> simulatedPercentages;
    private Double score;
    private  Map<TransportMode, Double> expectedPercentages;
    public double scoreIncome(Map<TransportMode, AtomicInteger> modeMap, File calibrationSet, String[] header,
    String[] params) throws FileNotFoundException {
        double sum = 0;
        // store in map (rather than array), since the CSV may be unordered.
         HashMap<TransportMode, Double> expectedProportions = new HashMap<>();
        HashMap<TransportMode, Double> scaledPercentages = new HashMap<>();

        for(Map.Entry<TransportMode,AtomicInteger> entry: modeMap.entrySet()){
            double value = entry.getValue().doubleValue();
            sum += value;
        }


        try (CSVReader reader = new CSVReader(new FileReader(calibrationSet))) {
            reader.skip(1); //skip header
            String[] nextRecord;
            while ((nextRecord = reader.readNext()) != null) {
                TransportMode transportMode = StringCodeTypeInterface.parseAsEnum(TransportMode.class, nextRecord[0]);
                Double percent = Double.parseDouble(nextRecord[2])/100;

                expectedProportions.put(transportMode, percent);
            }
        }catch (Exception exception){
            LOGGER.log(Level.SEVERE,"Cannot interpret file to score against" , exception);
            throw  new RuntimeException("Score file could not be understood.");
        }
        double score = 0;
        //Convert into percent, and make each income group add to 100%.

        for(Map.Entry<TransportMode,AtomicInteger> entry: modeMap.entrySet()){
            double simulatedValue = (entry.getValue().doubleValue()/sum);
            score += Math.pow(((simulatedValue-expectedProportions.get(entry.getKey()))*100),2);
            scaledPercentages.put(entry.getKey(), simulatedValue);
        }

        this.simulatedPercentages = scaledPercentages;
        this.expectedPercentages = expectedProportions;
        double finalScore = Math.sqrt(score/TransportMode.values().length);
        this.score = finalScore;
        return finalScore;
    }

    public void saveScore(File output_dir) throws IOException {
        if(score == null){
            throw new RuntimeException("Scoring must take place first");
        }
        Files.write(Paths.get(output_dir.toString(), "percentage_score.txt"), this.score.toString().getBytes());
    }
    public void saveDistribution(File output_dir) throws IOException {
        if(expectedPercentages == null|| simulatedPercentages == null){
            throw new RuntimeException("Scoring must take place first");
        }
        CSVWriter writer = new CSVWriter(new FileWriter(new File(output_dir, "xmode_percent.csv")));

        String[] row = new String[4];
        row[0] = "mode_choice";
        row[1] = "simulated percent";
        row[2] = "expected percent";
        row[3] = "difference";
        writer.writeNext(row);

        for (TransportMode mode : TransportMode.values()) {
            row = new String[4];
            row[0] = String.valueOf(mode);
            Double value = simulatedPercentages.get(mode);
            row[1] = String.valueOf(value*100);
            row[2] = String.valueOf(expectedPercentages.get(mode)*100);
            row[3] = String.valueOf((expectedPercentages.get(mode) - value)*100);
            writer.writeNext(row);
        }

        writer.close();
    }
}
