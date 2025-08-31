# MATLAB EEG Pre-processing Pipeline App

This MATLAB App provides a graphical user interface (GUI) for cleaning and pre-processing raw EEG data, designed for the Developmental Neurolinguistics Lab (DNL).

## Features

- Step-by-step GUI to guide the user through the pre-processing pipeline.
- Handles `.dat` files from Curry.
- Pipeline steps include: resampling, filtering, artifact rejection with clean_rawdata, ICA, and automated artifact classification with MARA.
- Allows for easy selection of trigger codes, channels to remove, and epoching parameters.

## Minimum Requirements

- MATLAB R2022a or higher
- EEGLAB Plugin V 2023 or higher
- EEGLAB Extensions:
    - MARA (v1.2)
    - loadcurry (v2.0)
    - clean_rawdata (v2.7)
    - Biosig (v3.8.1)
    - firfilt (v1.6.2)

## How to Use

1.  On this GitHub page, click the green **<> Code** button and select **Download ZIP**.
2.  Unzip the downloaded folder on your computer.
3.  Ensure all required EEGLAB extensions are installed and added to your MATLAB path.
4.  Open MATLAB.
5.  Navigate to the unzipped folder and run the `Pre_Processing_App_092224.mlapp` file.
6.  Follow the steps in the app's interface to select your data and configure parameters.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
