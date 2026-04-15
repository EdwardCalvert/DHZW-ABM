import subprocess
import os
import pandas as pd
from pathlib import Path
import numpy as np
from scipy import stats

def write_vot_config_file(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaChangesTransport,
        betaCostLow,
        betaCostMed,
        betaCostHigh,
        weightWalk,
        weightWait,
        weightFeeder,
        weightVotCosts,
        weightTangibleCosts,
        filename) -> int:
    data = {'alphaWalk' : alphaWalk,
                'alphaBike' :alphaBike,
                'alphaCarDriver': alphaCarDriver,
                'alphaCarPassenger':alphaCarPassenger,
                'alphaBus':alphaBus,
                'alphaTrain' :alphaTrain,
                'betaChangesTransport':betaChangesTransport,
                'betaCostLow' :betaCostLow, # betaCostLow,
                'betaCostMed' : betaCostMed,
                'betaCostHigh': betaCostHigh, #betaCostHigh,
                'votCommuteWalk': 15.89,
                'votCommuteBike': 10.17,
                'votCommuteCar': 10.78,
                'votCommuteBus': 7.62,
                'votCommuteTrain': 12.05,
                'votOtherWalk': 11.76,
                'votOtherBike': 10.43,
                'votOtherCar':9.60,
                'votOtherBus':6.66,
                'votOtherTrain':8.64,
                'carCostKm':0.25,
                'ptCostKm':0.187,
                'ptBaseCost':1.08,
                'weightWalk': weightWalk,# 2.0,
                'weightWait': weightWait, # 2.5,
                'weightFeeder': weightFeeder, # 2.0,
                'weightVotCosts' : weightVotCosts,
                'weightTangibleCosts' : weightTangibleCosts
                }
    if Path(filename).exists():
        config = pd.read_csv(filename)
        new_entry = pd.DataFrame([data])

        row_count = len(config) #Length off by one, so new index

        new_entry.to_csv(filename,mode='a',header=(not os.path.exists(filename)) , index = None)

        return row_count
    else:
        cols = [
        'alphaWalk', 'alphaBike', 'alphaCarDriver', 'alphaCarPassenger', 'alphaBus', 
        'alphaTrain', 'betaChangesTransport', 'betaCostLow', 'betaCostMed', 'betaCostHigh',
        'votCommuteWalk', 'votCommuteBike', 'votCommuteCar', 'votCommuteBus', 'votCommuteTrain',
        'votOtherWalk', 'votOtherBike', 'votOtherCar', 'votOtherBus', 'votOtherTrain',
        'carCostKm', 'ptCostKm', 'ptBaseCost', 'weightWalk','weightWait','weightFeeder', 'weightVotCosts',
        'weightTangibleCosts'
            ]
        
        df = pd.DataFrame([data], columns=cols)


        df.to_csv(filename, index=None)
        return 0
    
def write_stt_config_file(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaTimeWalk ,
        betaTimeBike,
        betaTimeCarDriver,
        betaTimeCarPassenger,
        betaTimeBus ,
        betaTimeTrain ,
        betaCostCarDriver,
        betaCostCarPassenger ,
        betaCostBus,
        betaCostTrain,
        betaTimeWalkTransport,
        betaChangesTransport,
        filename) -> int:

    cols = [
        'alphaWalk', 'alphaBike', 'alphaCarDriver', 'alphaCarPassenger', 'alphaBus', 
        'alphaTrain', 'betaTimeWalk' ,
           'betaTimeBike',
           'betaTimeCarDriver',
           'betaTimeCarPassenger',
           'betaTimeBus' ,
           'betaTimeTrain' ,
           'betaCostCarDriver',
           'betaCostCarPassenger' ,
           'betaCostBus',
           'betaCostTrain',
           'betaTimeWalkTransport',
           'betaChangesTransport',
           'carCostKm',
                'ptCostKm',
                'ptBaseCost',
            ]
        
    data = {'alphaWalk' : alphaWalk,
                'alphaBike' :alphaBike,
                'alphaCarDriver': alphaCarDriver,
                'alphaCarPassenger':alphaCarPassenger,
                'alphaBus':alphaBus,
                'alphaTrain' :alphaTrain,
                'betaTimeWalk' : betaTimeWalk,
                'betaTimeBike' : betaTimeBike,
                'betaTimeCarDriver': betaTimeCarDriver,
                'betaTimeCarPassenger' : betaTimeCarPassenger,
                'betaTimeBus' : betaTimeBus,
                'betaTimeTrain' : betaTimeTrain,
                'betaCostCarDriver': betaCostCarDriver,
                'betaCostCarPassenger' : betaCostCarPassenger,
                'betaCostBus': betaCostBus,
                'betaCostTrain': betaCostTrain,
                'betaTimeWalkTransport': betaTimeWalkTransport,
                'betaChangesTransport': betaChangesTransport,
                'carCostKm':0.25,
                'ptCostKm':0.187,
                'ptBaseCost':1.08,}
    if Path(filename).exists():
        config = pd.read_csv(filename)
        new_entry = pd.DataFrame([data], columns=cols)

        row_count = len(config) #Length off by one, so new index

        new_entry.to_csv(filename,mode='a',header=(not os.path.exists(filename)) , index = None)

        return row_count
    else:
     
        df = pd.DataFrame([data], columns=cols)


        df.to_csv(filename, index=None)
        return 0
    
    
    
def call_vot_simulation(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaChangesTransport,
        betaCostLow,
        betaCostMed,
        betaCostHigh,
        weightWalk,
        weightWait,
        weightFeeder,
        weightVotCosts,
        weightTangibleCosts,
        config
        ):
    

    parameter_set_index = write_vot_config_file(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaChangesTransport,
        betaCostLow,
        betaCostMed,
        betaCostHigh,
        weightWalk,
        weightWait,
        weightFeeder,
        weightVotCosts,
        weightTangibleCosts,
        config["parameterset_write_folder"] + config["parameterset"]
        )

    arg = f'--parameterset_index {parameter_set_index}'
    java_folder_path = '7-simulation-Sim-2APL'


    # set current directory the folder of Sim2APL so I can execute the jar with the correct paths
    if (os.path.basename(os.getcwd()) != java_folder_path):
        new_directory = os.path.join(os.getcwd(), "../", java_folder_path)
        new_directory = new_directory.replace('\\', '/')
        os.chdir(new_directory)

    full_command = f'java -cp target/sim2apl-dhzw-simulation-1.0-SNAPSHOT-jar-with-dependencies.jar main.java.nl.uu.iss.ga.Simulation --config {config["config_file"]} --output_file {config["output_path"]} --parameter_file {config["parameterset"]} {arg} {config["other_args"]}'

    try:
        output = subprocess.check_output(
            full_command, stderr=subprocess.STDOUT, universal_newlines=True)
        return -float(output)
    except subprocess.CalledProcessError as e:
        print(f"Java program exited with non-zero return code: {e.returncode}")
        print(f"Error message: {e.output}")
    return -999999999999 #an egregiously bad option.

def call_stt_simulation(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaTimeWalk ,
        betaTimeBike,
        betaTimeCarDriver,
        betaTimeCarPassenger,
        betaTimeBus ,
        betaTimeTrain ,
        betaCostCarDriver,
        betaCostCarPassenger ,
        betaCostBus,
        betaCostTrain,
        betaTimeWalkTransport,
        betaChangesTransport,
        config):
    
    parameter_set_index = write_stt_config_file(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaTimeWalk ,
        betaTimeBike,
        betaTimeCarDriver,
        betaTimeCarPassenger,
        betaTimeBus ,
        betaTimeTrain ,
        betaCostCarDriver,
        betaCostCarPassenger ,
        betaCostBus,
        betaCostTrain,
        betaTimeWalkTransport,
        betaChangesTransport,
        config["parameterset_write_folder"] + config["parameterset"]
        )
   
    arg = f'--parameterset_index {parameter_set_index}'
    java_folder_path = '7-simulation-Sim-2APL'
    
    # set current directory the folder of Sim2APL so I can execute the jar with the correct paths
    if (os.path.basename(os.getcwd()) != java_folder_path):
        new_directory = os.path.join(os.getcwd(), "../", java_folder_path)
        new_directory = new_directory.replace('\\', '/')
        os.chdir(new_directory)
    full_command = f'java -cp target/sim2apl-dhzw-simulation-1.0-SNAPSHOT-jar-with-dependencies.jar main.java.nl.uu.iss.ga.Simulation --config {config["config_file"]} --output_file {config["output_path"]} --parameter_file {config["parameterset"]} {arg} {config["other_args"]}'
    try:
        output = subprocess.check_output(
            full_command, stderr=subprocess.STDOUT, universal_newlines=True)
        return -float(output)
    except subprocess.CalledProcessError as e:
        print(f"Java program exited with non-zero return code: {e.returncode}")
        print(f"Error message: {e.output}")
        exit(1)
    return -999999999999 #an egregiously bad option.




def write_stt_unified_config_file(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaChangesTransport,
        betaTimeWalkTransport,
        betaCostLow,
        betaCostMed,
        betaCostHigh,
        votCommuteWalk,
        votCommuteBike,
        votCommuteCar,
        votCommutePassenger,
        votCommuteBus,
        votCommuteTrain,
        votOtherWalk,
        votOtherBike,
        votOtherCar,
        votOtherPassenger,
        votOtherBus,
        votOtherTrain,
        filename) -> int:  

    data = {'alphaWalk' : alphaWalk,
                'alphaBike' :alphaBike,
                'alphaCarDriver': alphaCarDriver,
                'alphaCarPassenger':alphaCarPassenger,
                'alphaBus':alphaBus,
                'alphaTrain' :alphaTrain,
                'betaChangesTransport':betaChangesTransport,
                'betaTimeWalkTransport' : betaTimeWalkTransport,
                'betaCostLow' :betaCostLow,
                'betaCostMed' : betaCostMed,
                'betaCostHigh': betaCostHigh,
                'votCommuteWalk': votCommuteWalk,
                'votCommuteBike': votCommuteBike,
                'votCommuteCar': votCommuteCar,
                'votCommutePassenger': votCommutePassenger,
                'votCommuteBus': votCommuteBus,
                'votCommuteTrain':votCommuteTrain,
                'votOtherWalk': votOtherWalk,
                'votOtherBike':votOtherBike,
                'votOtherCar':votOtherCar,
                'votOtherPassenger':votOtherPassenger,
                'votOtherBus':votOtherBus,
                'votOtherTrain':votOtherTrain,
                'carCostKm':0.25,
                'ptCostKm':0.187,
                'ptBaseCost':1.08,
                }
    if Path(filename).exists():
        config = pd.read_csv(filename)
        new_entry = pd.DataFrame([data])

        row_count = len(config) #Length off by one, so new index

        new_entry.to_csv(filename,mode='a',header=(not os.path.exists(filename)) , index = None)

        return row_count
    else:
        cols = [
        'alphaWalk', 'alphaBike', 'alphaCarDriver', 'alphaCarPassenger', 'alphaBus', 
        'alphaTrain', 'betaChangesTransport', 'betaTimeWalkTransport','betaCostLow', 'betaCostMed', 'betaCostHigh',
        'votCommuteWalk',
        'votCommuteBike',
        'votCommuteCar',
        'votCommutePassenger',
        'votCommuteBus',
        'votCommuteTrain',
        'votOtherWalk',
        'votOtherBike',
        'votOtherCar',
        'votOtherPassenger',
        'votOtherBus',
        'votOtherTrain',
        'carCostKm', 'ptCostKm', 'ptBaseCost'
            ]
        
        df = pd.DataFrame([data], columns=cols)


        df.to_csv(filename, index=None)
        return 0
    


    
def call_stt_unified_simulation(
        alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaChangesTransport,
        betaTimeWalkTransport,
        betaCostLow,
        betaCostMed,
        betaCostHigh,
        votCommuteWalk,
        votCommuteBike,
        votCommuteCar,
        votCommutePassenger,
        votCommuteBus,
        votCommuteTrain,
        votOtherWalk,
        votOtherBike,
        votOtherCar,
        votOtherPassenger,
        votOtherBus,
        votOtherTrain,
        config
        ):
    

    parameter_set_index = write_stt_unified_config_file(
       alphaWalk,
        alphaBike,
        alphaCarDriver,
        alphaCarPassenger,
        alphaBus,
        alphaTrain,
        betaChangesTransport,
        betaTimeWalkTransport,
        betaCostLow,
        betaCostMed,
        betaCostHigh,
        votCommuteWalk,
        votCommuteBike,
        votCommuteCar,
        votCommutePassenger,
        votCommuteBus,
        votCommuteTrain,
        votOtherWalk,
        votOtherBike,
        votOtherCar,
        votOtherPassenger,
        votOtherBus,
        votOtherTrain,
        config["parameterset_write_folder"] + config["parameterset"]
        )

    arg = f'--parameterset_index {parameter_set_index}'
    java_folder_path = '7-simulation-Sim-2APL'


    # set current directory the folder of Sim2APL so I can execute the jar with the correct paths
    if (os.path.basename(os.getcwd()) != java_folder_path):
        new_directory = os.path.join(os.getcwd(), "../", java_folder_path)
        new_directory = new_directory.replace('\\', '/')
        os.chdir(new_directory)

    full_command = f'java -cp target/sim2apl-dhzw-simulation-1.0-SNAPSHOT-jar-with-dependencies.jar main.java.nl.uu.iss.ga.Simulation --config {config["config_file"]} --output_file {config["output_path"]} --parameter_file {config["parameterset"]} {arg} {config["other_args"]}'

    try:
        output = subprocess.check_output(
            full_command, stderr=subprocess.STDOUT, universal_newlines=True)
        return -float(output)
    except subprocess.CalledProcessError as e:
        print(f"Java program exited with non-zero return code: {e.returncode}")
        print(f"Error message: {e.output}")
    return -999999999999 #an egregiously bad option.

def intialise_java():

    jdk_11_path = r"C:\Program Files\Java\jdk-11"

    os.environ["JAVA_HOME"] = jdk_11_path
    bin_path = os.path.join(jdk_11_path, "bin")
    os.environ["PATH"] = bin_path + os.pathsep + os.environ.get("PATH", "")

    # 4. Verification
    try:
        result = subprocess.run(["java", "-version"], capture_output=True, text=True, check=True)
        print("Java Version Output:\n", result.stderr) 
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
    except FileNotFoundError:
        print("Java executable not found in the updated PATH.")

STT_DIMENSIONS = 5
STT_INIT_POINTS = 100
STT_N_ITER = 300


VOT_DIMENSIONS = 9
VOT_INIT_POINTS = 180
VOT_N_ITER = 540

def stats_test(result1, result2):
    baseline = np.array(result1)
    improved = np.array(result2)

    t_stat, p_value = stats.ttest_ind(baseline, improved)

    print(f"P-value: {p_value}")
    if p_value < 0.05:
        print("Statistically significant difference.")
        
    #Confidence intervals
    n1, n2 = len(baseline), len(improved)
    mean1, mean2 = np.mean(baseline), np.mean(improved)
    diff = mean1 - mean2


    se_diff = np.sqrt(np.var(baseline, ddof=1)/n1 + np.var(improved, ddof=1)/n2)

    df = n1 + n2 - 2
    t_crit = stats.t.ppf(0.975, df)

    lower_bound = diff - (t_crit * se_diff)
    upper_bound = diff + (t_crit * se_diff)

    print(f"t-statistic: {t_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"95% CI of the difference: [{lower_bound:.4f}, {upper_bound:.4f}]")