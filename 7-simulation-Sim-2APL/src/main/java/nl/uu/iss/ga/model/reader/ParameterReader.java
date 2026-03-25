package main.java.nl.uu.iss.ga.model.reader;

import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ParameterReader {
    CSVReader reader;
    private static final Logger LOGGER = Logger.getLogger(ParameterReader.class.getName());
    private Map<String, String> parameterSet = new HashMap<>();

    public ParameterReader(String parameterFilePath, int parameterSetIndex){
        this.loadParameters(new File(parameterFilePath), parameterSetIndex);
    }

    private void loadParameters(File routingFile, int parameterSetIndex){
        LOGGER.log(Level.INFO, "Reading parameters MNL file " + routingFile.toString());

        try {
            this.reader = new CSVReader(new FileReader(routingFile));
            String[] headers = reader.readNext(); // Capture keys
            reader.skip(parameterSetIndex);
            String[] values = reader.readNext();

            for (int i = 0; i < headers.length; i++) {
                parameterSet.put(headers[i], values[i]);
            }
        }catch (IOException | CsvValidationException e) {
            throw new RuntimeException(e);
        }
        LOGGER.log(Level.INFO, "Read " + parameterSet);
    }
    public double getDoubleParameter(String paramName) {
        if (!parameterSet.containsKey(paramName)) {
            throw new RuntimeException("Parameter " + paramName + " not found.");
        }
        return Double.parseDouble(this.parameterSet.get(paramName));
    }

}
