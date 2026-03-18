package main.java.nl.uu.iss.ga.model.reader;

import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ParameterReader {
    CSVReader reader;
    private static final Logger LOGGER = Logger.getLogger(ParameterReader.class.getName());
    private String[] parameterSet;

    public ParameterReader(String parameterFilePath, int parameterSetIndex){
        this.loadParameters(new File(parameterFilePath), parameterSetIndex);
    }

    private void loadParameters(File routingFile, int parameterSetIndex){
        LOGGER.log(Level.INFO, "Reading parameters MNL file " + routingFile.toString());

        try {
            this.reader = new CSVReader(new FileReader(routingFile));
            reader.skip(parameterSetIndex);
            this.parameterSet = reader.readNext();

            // Skip the first line of the CSV file (the header)
            reader.skip(parameterSetIndex);
        }catch (IOException | CsvValidationException e) {
            throw new RuntimeException(e);
        }
        LOGGER.log(Level.INFO, "Read " + parameterSet[0]);
    }
    public double getDoubleParameter(int paramIndex){
        if(paramIndex>= parameterSet.length || paramIndex <0){
            throw new RuntimeException("You attempted to access a parameter with an index greater than that in the file");
        }
        return Double.parseDouble(this.parameterSet[paramIndex]);
    }

    public String getParameter(int paramIndex){
        if(paramIndex>= parameterSet.length || paramIndex <0){
            throw new RuntimeException("You attempted to access a parameter with an index greater than that in the file");
        }
        return this.parameterSet[paramIndex];
    }
}
