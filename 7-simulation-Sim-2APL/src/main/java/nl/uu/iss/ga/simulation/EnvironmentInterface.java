package main.java.nl.uu.iss.ga.simulation;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import com.opencsv.exceptions.CsvValidationException;
import main.java.nl.uu.iss.ga.Simulation;
import main.java.nl.uu.iss.ga.model.data.Activity;
import main.java.nl.uu.iss.ga.model.data.dictionary.ActivityType;
import main.java.nl.uu.iss.ga.model.data.dictionary.DayOfWeek;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.households.IncomeThirds;
import main.java.nl.uu.iss.ga.model.data.dictionary.util.CodeTypeInterface;
import main.java.nl.uu.iss.ga.util.IncomeFitnessFunctionScorer;
import main.java.nl.uu.iss.ga.util.PercentageFitnessFunctionScorer;
import main.java.nl.uu.iss.ga.util.config.ArgParse;
import main.java.nl.uu.iss.ga.util.config.ConfigModel;
import main.java.nl.uu.iss.ga.util.tracking.ModeOfTransportTracker;
import nl.uu.cs.iss.ga.sim2apl.core.deliberation.DeliberationResult;
import nl.uu.cs.iss.ga.sim2apl.core.tick.TickHookProcessor;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EnvironmentInterface implements TickHookProcessor<Activity> {

    private static final Logger LOGGER = Logger.getLogger(EnvironmentInterface.class.getName());
    private final boolean printOutput = false;
    private final ConfigModel config;
    private final ArgParse arguments;
    private final LocalDate startDate;
    private long currentTick = 0;
    private LocalDateTime simulationStarted;
    private DayOfWeek today = DayOfWeek.MONDAY;

    private ModeOfTransportTracker modeOfTransportTracker;


    public EnvironmentInterface(
            ArgParse arguments,
            ModeOfTransportTracker modeOfTransportTracker,

            ConfigModel config
    ) {
        this.arguments = arguments;
        this.modeOfTransportTracker = modeOfTransportTracker;

        this.config = config;
        this.startDate = arguments.getStartdate();

        if (this.startDate != null) {
            this.today = DayOfWeek.fromDate(this.startDate);
            LOGGER.log(Level.INFO, "Start date set to " + this.startDate.format(DateTimeFormatter.ofPattern("cccc dd MMMM yyyy")));
        }
    }

    public void setSimulationStarted() {
        this.simulationStarted = LocalDateTime.now();
        modeOfTransportTracker.reset();
    }

    public long getCurrentTick() {
        return currentTick;
    }

    public DayOfWeek getToday() {
        return today;
    }

    @Override
    public void tickPreHook(long tick) {
        this.currentTick = tick;
        if (this.startDate == null) {
            this.today = CodeTypeInterface.parseAsEnum(DayOfWeek.class, (int) (currentTick % 7 + 1));
        } else {
            this.today = DayOfWeek.fromDate(this.startDate.plusDays(tick));
        }

        String date = this.startDate.plusDays(tick).format(DateTimeFormatter.ISO_DATE);
    }

    @Override
    public void tickPostHook(long tick, int lastTickDuration, List<Future<DeliberationResult<Activity>>> agentActions) {
        LOGGER.log(Level.FINE, String.format(
                "Tick %d took %d milliseconds for %d agents (roughly %fms per agent)",
                tick, lastTickDuration, agentActions.size(), (double) lastTickDuration / agentActions.size()));
    }

    @Override
    public void simulationFinishedHook(long l, int i) {
        Duration startupDuration = Duration.between(Simulation.instantiated, this.simulationStarted);
        Duration simulationDuration = Duration.between(this.simulationStarted, LocalDateTime.now());
        Duration combinedDuration = Duration.between(Simulation.instantiated, LocalDateTime.now());
        LOGGER.log(Level.INFO, String.format(
                "Simulation finished.\n\tInitialization took\t\t%s.\n\tSimulation took\t\t\t%s for %d time steps.\n\tTotal simulation time:\t%s",
                prettyPrint(startupDuration),
                prettyPrint(simulationDuration),
                l,
                prettyPrint(combinedDuration))
        );

        if (printOutput) {
            int sum = 0;


            System.out.println("\nMode x day:");
            AtomicInteger[][] modeDayMap = modeOfTransportTracker.getModeDayMap();
            for (DayOfWeek day : DayOfWeek.values()) {
                System.out.println(day + ":");
                for (TransportMode mode : TransportMode.values()) {
                    System.out.println(" " + mode + ": " + modeDayMap[day.ordinal()][mode.ordinal()]);
                }
            }

            System.out.println("\nMode x activity:");
            AtomicInteger[][] modeActivityMap = modeOfTransportTracker.getModeActivityMap();
            for (ActivityType activity : ActivityType.values()) {
                System.out.println(activity + ":");
                for (TransportMode mode : TransportMode.values()) {
                    System.out.println(" " + mode + ": " + modeActivityMap[activity.ordinal()][mode.ordinal()]);
                }
            }

            System.out.println("\nMode x car license:");
            AtomicInteger[][] modeCarLicenseMap = modeOfTransportTracker.getModeCarLicenseMap();
            for (boolean b : new boolean[]{true, false}) {
                System.out.println(b + ":");
                for (TransportMode mode : TransportMode.values()) {
                    System.out.println(" " + mode + ": " + modeCarLicenseMap[b ? 1 : 0][mode.ordinal()]);
                }
            }

            System.out.println("\nMode x car ownership:");
            AtomicInteger[][] modeCarOwnership = modeOfTransportTracker.getModeCarOwnershipMap();
            for (boolean b : new boolean[]{true, false}) {
                System.out.println(b + ":");
                for (TransportMode mode : TransportMode.values()) {
                    System.out.println(" " + mode + ": " + modeCarOwnership[b ? 1 : 0][mode.ordinal()]);
                }
            }
            System.out.println("\nIncome group x activity type");

            AtomicInteger[][] incomeModeMap = modeOfTransportTracker.getIncomeModeMap();
            for (IncomeThirds incomeThird : IncomeThirds.values()) {
                System.out.println(incomeThird + ":");
                for (TransportMode mode : TransportMode.values()) {
                    System.out.println(" " + mode + ": " + incomeModeMap[incomeThird.ordinal()][mode.ordinal()]);
                }
            }
            for (Map.Entry<TransportMode, AtomicInteger> entry : modeOfTransportTracker.getTotalModeMap().entrySet()) {
                AtomicInteger count = entry.getValue();
                sum += count.get();
            }

            System.out.println("\nOverall mode choices:");
            System.out.println(modeOfTransportTracker.getTotalModeMap());
            System.out.printf("Total trips: %s", sum);
        }
        File output_dir = this.config.getDistributionOutputBaseFolder();
        try {

            modeOfTransportTracker.appendOutput(this.arguments.getOutputFile());
            modeOfTransportTracker.saveTotalModeToCsv(output_dir);
            modeOfTransportTracker.saveDistanceToCsv(output_dir);
            modeOfTransportTracker.saveModeDayToCsv(output_dir);
            modeOfTransportTracker.saveModeActivityToCsv(output_dir);
            modeOfTransportTracker.saveModeCarLicenseToCsv(output_dir);
            modeOfTransportTracker.saveModeCarOwnershipToCsv(output_dir);
            modeOfTransportTracker.saveIncomeModeMap(output_dir);
            if(true) {
                modeOfTransportTracker.saveODMatrix(output_dir);
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (CsvValidationException e) {
            throw new RuntimeException(e);
        }
        //Create a copy of the parameterset in the output folder,
        // so that my head doesn't blow up when I look at the results
        try{
            //Copy configuration file.
            File configurationFile = arguments.getConfiguration();
            Files.copy(configurationFile.toPath(), Paths.get(output_dir.toString(), configurationFile.getName()));

            //Copy parameterset, useful for debugging etc
            String[] header;
            String[] params;
            try (CSVReader parameterSetReader = new CSVReader(new FileReader(arguments.getParameterSetFile()))) {
                header = parameterSetReader.readNext();
                parameterSetReader.skip(this.arguments.getParameterSetIndex());
                params = parameterSetReader.readNext();
            }

            File outputFile = Paths.get(output_dir.toString(), "paramset.csv").toFile();
            try (CSVWriter writer = new CSVWriter(new FileWriter(outputFile))) {
                writer.writeNext(header);
                writer.writeNext(params);
            }
            IncomeFitnessFunctionScorer incomeScorer = new IncomeFitnessFunctionScorer();
            //Write output score instead
            Double score = incomeScorer.scoreIncome(modeOfTransportTracker.getIncomeModeMap(), new File("src/main/resources/calibration_files/DHZW_income_group_proportions.csv"));
            incomeScorer.saveScore(output_dir);
            incomeScorer.saveIncome(output_dir);

            PercentageFitnessFunctionScorer percentageScorer = new PercentageFitnessFunctionScorer();
            Double percentageScore = percentageScorer.scoreIncome(modeOfTransportTracker.getTotalModeMap(),
                    new File("src/main/resources/calibration_files/DHZW_modal_choice_proporitions.csv"),
                    header,
                    params
            );
            percentageScorer.saveScore(output_dir);
            percentageScorer.saveDistribution(output_dir);

            if(config.getScoreAgainst().equals("income")){
                System.out.print(score);
            }
            else if(config.getScoreAgainst().equals("percent")){
                System.out.print(percentageScore);
            }
            else{
                System.out.print("The score setting couldn't be understood");
            }

        }
        catch (Exception e){
            LOGGER.log(Level.SEVERE, "Attempted to copy the parameter set and the configuration file to the output dir, but failed.");
        }
    }

    /**
     * Pretty print a duration
     *
     * @param duration Duration object to pretty print
     * @return Pretty printed duration
     */
    private String prettyPrint(Duration duration) {
        return duration.toString()
                .substring(2)
                .replaceAll("(\\d[HMS])(?!$)", "$1 ")
                .toLowerCase();
    }


}
