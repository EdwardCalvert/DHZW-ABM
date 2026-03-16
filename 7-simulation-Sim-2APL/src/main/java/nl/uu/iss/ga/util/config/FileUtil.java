package main.java.nl.uu.iss.ga.util.config;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class FileUtil {
    public static void ensureFolderExists(Path filePath) throws IOException {
        if(filePath.getParent() != null){
            Files.createDirectories(filePath.getParent());
        }
        if(Files.notExists(filePath)){
            Files.createDirectory(filePath);
        }
    }
}
