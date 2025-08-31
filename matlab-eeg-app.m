classdef Pre_Processing_App_092224 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel  matlab.ui.control.Label
        MinimumRequirementsLabel        matlab.ui.control.Label
        Hyperlink                       matlab.ui.control.Hyperlink
        Image                           matlab.ui.control.Image
        Label                           matlab.ui.control.Label
        CenterPanel                     matlab.ui.container.Panel
        File_Lists_2                    matlab.ui.control.ListBox
        NonChan_ListListBox             matlab.ui.control.ListBox
        Trigger_Code_ListListBox        matlab.ui.control.ListBox
        EpochingEditField               matlab.ui.control.EditField
        Epoching_Queue                  matlab.ui.control.Image
        AveRefEditField                 matlab.ui.control.EditField
        AveRef_Queue                    matlab.ui.control.Image
        MARAEditField                   matlab.ui.control.EditField
        MARA_Queue                      matlab.ui.control.Image
        ICAEditField                    matlab.ui.control.EditField
        ICA_Queue                       matlab.ui.control.Image
        ChanLocEditField                matlab.ui.control.EditField
        ChanLoc_Queue                   matlab.ui.control.Image
        Save_preprocEditField           matlab.ui.control.EditField
        Save_preproc_Queue              matlab.ui.control.Image
        clean_rawdataEditField          matlab.ui.control.EditField
        clean_rawdata_Queue             matlab.ui.control.Image
        LPFilter_Queue                  matlab.ui.control.Image
        LPFilterEditField               matlab.ui.control.EditField
        HPFilterEditField               matlab.ui.control.EditField
        HPFilter_Queue                  matlab.ui.control.Image
        Resampling_Queue                matlab.ui.control.Image
        ResamplingEditField             matlab.ui.control.EditField
        ProgressLabel                   matlab.ui.control.Label
        Number_DoneEditField            matlab.ui.control.EditField
        NumberofFilesPreProcessedLabel  matlab.ui.control.Label
        Current_StudyEditField          matlab.ui.control.EditField
        CurrentProcessingFileLabel      matlab.ui.control.Label
        RightPanel                      matlab.ui.container.Panel
        Cover_Right_Panel               matlab.ui.control.Label
        Source_Directory                matlab.ui.control.ListBox
        BrowseButton                    matlab.ui.control.Button
        File_Lists                      matlab.ui.control.ListBox
        Getting_Channel                 matlab.ui.control.Image
        GettingChannelInformationLabel  matlab.ui.control.Label
        StartButton_2                   matlab.ui.control.Button
        NonChanEditField                matlab.ui.control.EditField
        AddNonChanButton                matlab.ui.control.Button
        TriggersEditField               matlab.ui.control.EditField
        DoneButton                      matlab.ui.control.Button
        CleartheListButton              matlab.ui.control.Button
        AddtriggercodeButton            matlab.ui.control.Button
        Enter_Epoching_CodeEditField    matlab.ui.control.EditField
        StartButton                     matlab.ui.control.Button
        Step7ElectrodesToRemoveLabel    matlab.ui.control.Label
        Step8ChoosetheoutputLabel       matlab.ui.control.Label
        Step4ChoosethenumberofICAcomponentsremovedbyMARALabel  matlab.ui.control.Label
        Step2ResamplingRateLabel        matlab.ui.control.Label
        Output_FileEditField            matlab.ui.control.EditField
        OutputSelectthefolderthatyouwanttosavedatainLabel  matlab.ui.control.Label
        OutputButton                    matlab.ui.control.Button
        Step6EpochingTriggerCodesLabel  matlab.ui.control.Label
        secondsfromtheonsetofthetriggercodetoLabel  matlab.ui.control.Label
        Epoching_MaxEditField           matlab.ui.control.NumericEditField
        Epoching_minEditField           matlab.ui.control.NumericEditField
        NumberofMARAComponentsEditField  matlab.ui.control.NumericEditField
        NumberofMARAComponentsEditFieldLabel  matlab.ui.control.Label
        Low_CutEditField                matlab.ui.control.NumericEditField
        Low_CutEditFieldLabel           matlab.ui.control.Label
        Step5EpochingMarginLabel        matlab.ui.control.Label
        Step3FilterRangeLabel           matlab.ui.control.Label
        Button                          matlab.ui.control.Button
        High_CutEditField               matlab.ui.control.NumericEditField
        High_CutEditFieldLabel          matlab.ui.control.Label
        ResamplingRateEditField         matlab.ui.control.NumericEditField
        ResamplingRateEditFieldLabel    matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end


    methods (Access = public)
        function Getting_File_Dir(app)

            Desired_Extensions = {'.dat'};
            Desired_Directory = {};
            Source_Folder = uigetdir(pwd,'Select the source folder that has the raw EEG files');   
            Files_Info = dir(fullfile(Source_Folder, ['**' filesep '*.*']));%Files_Info = dir(fullfile(Source_Folder, '**\\*.*'));
            Files_Info = struct2cell(Files_Info)';
            
            %Check for EEG_Files
            Files = cellfun(@(x) isequal(x, 0), Files_Info(:,5));
            Files_Names = Files_Info(Files,1);
            Desired_Index = contains(Files_Names,Desired_Extensions);
            Desired_Files = Files_Names(Desired_Index,:);
            Folder_Names = Files_Info(Files,2);
            Folder_Names = Folder_Names(Desired_Index,:);
            File_Counter = 0;
                for Fi = 1: length (Desired_Files)
                    Current_Dir = [Folder_Names{Fi} filesep Desired_Files{Fi}];
                    File_Counter = File_Counter+1;
                    Desired_Directory{File_Counter,1} = Current_Dir;
                end
                app.Source_Directory.Items = erase(Folder_Names,Source_Folder);
                app.File_Lists.Items = Desired_Directory;
                drawnow
        end

        function results = Pre_Processing(app)

            Subject_Names= app.Source_Directory.Items
            Data_Address= app.File_Lists.Items
            Resampling_Rate = app.ResamplingRateEditField.Value;
            Low_Cut = app.Low_CutEditField.Value;
            High_Cut = app.High_CutEditField.Value;
            Margin_MARA = app.NumberofMARAComponentsEditField.Value;
            Epoching_min = app.Epoching_minEditField.Value;
            Epoching_Max = app.Epoching_MaxEditField.Value;
            Epoching_Codes = app.Trigger_Code_ListListBox.Items
            Logo_Folders = [pwd filesep]; %'K:\Dept\CallierResearch\Maguire\For PhD use\Mohammad\Pre_Processing_Pipeline\App\2\';

            count = 0;
            for Subject = 1:length(Subject_Names)
                
                if isempty(Subject_Names{Subject})
                    count = count+1;
                    Parent_Dir = fileparts(Data_Address{Subject});
                    Subject_Names{Subject} = '';%[erase(erase(Parent_Dir,fileparts(Parent_Dir)),filesep)];
                    Data_Address{Subject} = Data_Address{Subject};
                end
            end
            Subject_Names
            Data_Address 
           clear Subject count Subject_Names_Temp Data_Address_Temp

            for Subject = 1:length(Data_Address)
                if isfile(Data_Address{Subject}) && contains(Data_Address{Subject},'.dat')
                    Output_Folder = cat(2,app.Output_FileEditField.Value,Subject_Names{Subject},filesep);
                    if ~exist(Output_Folder, 'dir')
                        mkdir(Output_Folder);
                    end
                    
                    app.Resampling_Queue.Enable = 'off';
                    app.ResamplingEditField.Enable = 'off';
                    app.Resampling_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.HPFilter_Queue.Enable = 'off';
                    app.HPFilterEditField.Enable = 'off';
                    app.HPFilter_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.LPFilter_Queue.Enable = 'off';
                    app.LPFilterEditField.Enable = 'off';
                    app.LPFilter_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.clean_rawdata_Queue.Enable = 'off';
                    app.clean_rawdataEditField.Enable = 'off';
                    app.clean_rawdata_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.Save_preproc_Queue.Enable = 'off';
                    app.Save_preprocEditField.Enable = 'off';
                    app.Save_preproc_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.ChanLoc_Queue.Enable = 'off';
                    app.ChanLocEditField.Enable = 'off';
                    app.ChanLoc_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.ICA_Queue.Enable = 'off';
                    app.ICAEditField.Enable = 'off';
                    app.ICA_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.MARA_Queue.Enable = 'off';
                    app.MARAEditField.Enable = 'off';
                    app.MARA_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.AveRef_Queue.Enable = 'off';
                    app.AveRefEditField.Enable = 'off';
                    app.AveRef_Queue.ImageSource = [Logo_Folders, 'Queue.png'];

                    app.Epoching_Queue.Enable = 'off';
                    app.EpochingEditField.Enable = 'off';
                    app.Epoching_Queue.ImageSource = [Logo_Folders, 'Queue.png'];
                    drawnow


                    Pre_Processig_Log = {};
                    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                    EEG = pop_loadcurry(Data_Address{Subject}, 'dataformat', 'auto', 'keystroke', 'on');
                    Current_Study = erase(EEG.filename,'.dap');
                    Current_Study =  regexprep(Current_Study, ' +', '_');

                    app.Current_StudyEditField.Value = Current_Study;
                    app.Number_DoneEditField.Value = [num2str(Subject) ' out of ' num2str(length(Data_Address))];
                    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,  'setname', [Current_Study '_preproc'], 'gui', 'off' );

                    EEG=pop_editset(EEG, 'subject', Current_Study);
                    eeglab redraw


                    
                    Channel_Remove = app.NonChan_ListListBox.Value;

                    Pre_Processig_Log = cat(2,Pre_Processig_Log,{'Original'},size(EEG.data));
                    EEG=pop_select(EEG, 'nochannel', Channel_Remove );
                    [ALLEEG EEG CURRENTSET]= pop_newset(ALLEEG, EEG, 1, 'overwrite', 'on', 'gui', 'off');
                    [ALLEEG EEG]= eeg_store(ALLEEG, EEG, CURRENTSET);
                    EEG1.chanlocs = EEG.chanlocs;
                    Pre_Processig_Log = cat(2,Pre_Processig_Log,{'Channel_Removal'},Channel_Remove,size(EEG.data));
                    %% resample at new rate
                    app.Resampling_Queue.Enable = 'on';
                    app.ResamplingEditField.Enable = 'on';
                    app.Resampling_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];
                    drawnow

                    EEG=pop_resample(EEG,Resampling_Rate);
                    [ALLEEG EEG CURRENTSET]=pop_newset(ALLEEG, EEG,1, 'overwrite', 'on', 'gui', 'off');
                    [ALLEEG EEG]= eeg_store(ALLEEG, EEG, CURRENTSET);
                    app.Resampling_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow

                    %% Remove Extra Data
                    EEG = erplab_deleteTimeSegments(EEG, 0, 7000, 7000);
                    [ALLEEG EEG CURRENTSET]=pop_newset(ALLEEG, EEG,1, 'overwrite', 'on', 'gui', 'off');
                    EEG = eeg_checkset( EEG );

                    %% band pass filter
                    app.HPFilter_Queue.Enable = 'on';
                    app.HPFilterEditField.Enable = 'on';
                    app.LPFilter_Queue.Enable = 'on';
                    app.LPFilterEditField.Enable = 'on';
                    app.HPFilter_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow
                    app.LPFilter_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow
                    EEG = pop_eegfiltnew(EEG,Low_Cut,High_Cut);
                    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:62] ,'computepower',1,'linefreqs',60,'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
                    [ALLEEG EEG CURRENTSET]=pop_newset(ALLEEG, EEG,1, 'overwrite', 'on', 'gui', 'off');
                    [ALLEEG EEG]= eeg_store(ALLEEG, EEG, CURRENTSET);
                    app.HPFilter_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow
                    app.LPFilter_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow
                    %EEG = pop_eegfiltnew(EEG, 0.1,100,33000,0,[],0);

                    
                    %% clean raw EEG data
                    app.clean_rawdata_Queue.Enable = 'on';
                    app.clean_rawdataEditField.Enable = 'on';
                    app.clean_rawdata_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow
                    EEG = clean_rawdata(EEG, CURRENTSET, [0.25 0.75], 0.5, 4, 10, 'off');
                    EEG = eeg_checkset( EEG );
                    EEG = eeg_checkset( EEG );
                    app.clean_rawdata_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow

                    %saving output file
                    app.Save_preproc_Queue.Enable = 'on';
                    app.Save_preprocEditField.Enable = 'on';
                    app.Save_preproc_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow
                    EEG = eeg_checkset( EEG );
                    EEG = pop_saveset( EEG, [Output_Folder Current_Study '_preproc.set']);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    app.Save_preproc_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow   
                    Pre_Processig_Log = cat(2,Pre_Processig_Log,{'Cleaned_Filtered'},Resampling_Rate,[Low_Cut,High_Cut],size(EEG.data));

                    %% Channel Location and Interpolation %%
                    app.ChanLoc_Queue.Enable = 'on';
                    app.ChanLocEditField.Enable = 'on';
                    app.ChanLoc_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow
                    
                    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                    EEG = pop_loadset ([Output_Folder Current_Study '_preproc.set']);
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

                    EEG = eeg_checkset( EEG );
                    EEG = pop_epoch( EEG, Epoching_Codes , [Epoching_min.*2 Epoching_Max.*2],'epochinfo', 'yes');
                    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
                    EEG = eeg_checkset( EEG );
   

                    EEG = pop_interp(EEG, eeg_mergelocs(EEG1.chanlocs), 'spherical');    
                    EEG = pop_saveset( EEG, [Output_Folder Current_Study '_cleaned.set']);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

                    app.ChanLoc_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow  
                    
                    %% Prepoc ICA %%
                    app.ICA_Queue.Enable = 'on';
                    app.ICAEditField.Enable = 'on';
                    app.ICA_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow

                    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                    EEG = pop_loadset ([Output_Folder Current_Study '_cleaned.set']);
                    EEG= pop_runica(EEG,'extended',1,'interupt', 'on');
                    [ALLEEG EEG] = eeg_store(ALLEEG,EEG,CURRENTSET)
                    eeglab redraw
                    EEG = pop_saveset( EEG, [Output_Folder Current_Study '_ICA.set']);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

                    app.ICA_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow 
                    Pre_Processig_Log = cat(2,Pre_Processig_Log,{'ICA'},size(EEG.icaweights),size(EEG.data));
                    %% MARA Artifact Rejection %%
                    app.MARA_Queue.Enable = 'on';
                    app.MARAEditField.Enable = 'on';
                    app.MARA_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow

                    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                    EEG = pop_loadset ([Output_Folder Current_Study '_ICA.set']);
               
                    %[ALLEEG,EEG,CURRENTSET] = processMARA(ALLEEG,EEG,CURRENTSET);
                    %EEG = eeg_checkset( EEG );


                    
                    %Rejected_Artifact = find(EEG.reject.gcompreject(1:Margin_MARA) == 1);


                    [ALLEEG, EEG, EEG.reject.gcompreject ] = processMARA (ALLEEG, EEG,CURRENTSET) ;

%                     rejects components above 90% probability
                    EEG.reject.gcompreject = zeros(size(EEG.reject.gcompreject)); 
                    EEG.reject.gcompreject(EEG.reject.MARAinfo.posterior_artefactprob(:, [Margin_MARA+1:end]) > 0.01) = 0;
                    EEG.reject.gcompreject(EEG.reject.MARAinfo.posterior_artefactprob(:, [1:Margin_MARA]) > 0.90) = 1;
                    Pre_Processig_Log = cat(2,Pre_Processig_Log,{'MARA'},[EEG.reject.MARAinfo.posterior_artefactprob(:, [1:Margin_MARA]) > 0.90],size(EEG.data));
%                     EEG = pop_subcomp( EEG, Rejected_Artifact, 0);                  
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

                    
                    EEG = pop_interp(EEG, eeg_mergelocs(EEG1.chanlocs), 'spherical');
                    [ALLEEG EEG] = eeg_store(ALLEEG,EEG,CURRENTSET);
                    eeglab redraw
                    
                    EEG=pop_select(EEG, 'nochannel', Channel_Remove);
                    [ALLEEG EEG CURRENTSET]= pop_newset(ALLEEG, EEG, 1, 'overwrite', 'on', 'gui', 'off');
                    [ALLEEG EEG]= eeg_store(ALLEEG, EEG, CURRENTSET);
 
                    EEG = pop_saveset( EEG, [Output_Folder Current_Study '_artrej.set']);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    eeglab redraw;

                    app.MARA_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow
                    
                    %% Average Referencing %%
                    app.AveRef_Queue.Enable = 'on';
                    app.AveRefEditField.Enable = 'on';
                    app.AveRef_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow

                    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                    EEG = pop_loadset ([Output_Folder Current_Study '_artrej.set']);

                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                    EEG = eeg_checkset( EEG );
                    EEG = pop_reref( EEG, []);
                    EEG = pop_saveset( EEG, [Output_Folder Current_Study '_averef.set']);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    eeglab redraw;

                    app.AveRef_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow
                    
                    %% Pre Epoching %%
                    app.Epoching_Queue.Enable = 'on';
                    app.EpochingEditField.Enable = 'on';
                    app.Epoching_Queue.ImageSource = [Logo_Folders, 'In_Progress.gif'];drawnow

                    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                    
                    EEG = pop_loadset ([Output_Folder Current_Study '_averef.set']);
                    
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, CURRENTSET );
                    EEG = eeg_checkset( EEG );
                    EEG = pop_epoch( EEG, Epoching_Codes , [Epoching_min Epoching_Max], 'newname', [Current_Study '_PreEpoch.set'], 'epochinfo', 'yes');
                    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
                    EEG = eeg_checkset( EEG );
   
                    EEG = pop_saveset( EEG, [Output_Folder Current_Study '_PreEpoch.set']);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    eeglab redraw;

                    app.Epoching_Queue.ImageSource = [Logo_Folders, 'Done.png']; drawnow
                    Pre_Processig_Log = cat(2,Pre_Processig_Log,{'Epoch'},size(EEG.data));

                    save([Output_Folder Current_Study '_Cleaning_Log.mat'], 'Pre_Processig_Log');

                end
            end
        end
        
        function results = Execute(app)
            return
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Callback function
        function BrowseButtonPushed(app, event)

            [file,path] = uigetfile('K:\Dept\CallierResearch\Maguire\','Please select the excel file that has the data information','*.xlsx');
            Excel_Info = [path file];
            clear path file
            app.SelectedFileEditField.Value = Excel_Info;  
            app.ChoosethetypeoffileyouwanttopreprocessButtonGroup.Enable = 'on';
            app.Step2ResamplingRateLabel.Enable = 'on';
            app.ResamplingRateEditField.Enable = 'on';
            app.ResamplingRateEditFieldLabel.Enable = 'on';
            app.Step3FilterRangeLabel.Enable = 'on';
            app.High_CutEditField.Enable = 'on';
            app.Low_CutEditField.Enable = 'on';
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.Enable = 'on';
            app.NumberofMARAComponentsEditField.Enable = 'on';
            app.Step5EpochingMarginLabel.Enable = 'on';
            app.secondsfromtheonsetofthetriggercodetoLabel.Enable = 'on';
            app.Epoching_MaxEditField.Enable = 'on';
            app.Epoching_minEditField.Enable = 'on';
            app.Step6EpochingTriggerCodesLabel.Enable = 'on';
            app.Enter_Epoching_CodeEditField.Enable = 'on';
            app.AddtriggercodeButton.Enable = 'on';
            app.CleartheListButton.Enable = 'on';
            app.DoneButton.Enable = 'on';
            app.Trigger_Code_ListListBox.Visible = 'on';
            app.CurrentProcessingFileLabel.Text = 'Trigger Codes';
            app.Step1ChooseDataInformstionExcelFileLabel.BackgroundColor = [0.47,0.67,0.19];


        end

        % Button pushed function: OutputButton
        function OutputButtonPushed(app, event)

            Path = uigetdir('K:\Dept\CallierResearch\Maguire\','Please select the output folder');
            Output_Folder = Path;
            clear path file
            app.Output_FileEditField.Value = Output_Folder;
            app.Step8ChoosetheoutputLabel.BackgroundColor = [0.47,0.67,0.19];
            app.StartButton.Enable = 'on';
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            app.StartButton.Enable = 'off';drawnow;
            app.RightPanel.Enable = 'off';
            drawnow
            Pre_Processing(app)
        end

        % Callback function
        function BrowseButton_3Pushed(app, event)
            [file,path] = uigetfile('K:\Dept\CallierResearch\Maguire\','Please select the .MAT file that has the EEGLAB environmetn','*.MAT');
            EEGLAB_Env = [path file];
            clear path file
            app.EEGLAB_FIleEditField.Value = EEGLAB_Env;
        end

        % Value changed function: Trigger_Code_ListListBox
        function Trigger_Code_ListListBoxValueChanged(app, event)
            value = app.Trigger_Code_ListListBox.Value;
            
        end

        % Button pushed function: AddtriggercodeButton
        function AddtriggercodeButtonPushed(app, event)

            Trigger_Tempt = string(app.Enter_Epoching_CodeEditField.Value);
            app.Trigger_Code_ListListBox.Items = cat(2,app.Trigger_Code_ListListBox.Items,Trigger_Tempt);
            app.Enter_Epoching_CodeEditField.Value = '';

        end

        % Button pushed function: CleartheListButton
        function CleartheListButtonPushed(app, event)
            app.Trigger_Code_ListListBox.Items = {};
        end

        % Button pushed function: DoneButton
        function DoneButtonPushed(app, event)
            app.Trigger_Code_ListListBox.Visible = 'off';            
            app.CurrentProcessingFileLabel.Text = 'Wait...';
            app.Trigger_Code_ListListBox.Items = unique(app.Trigger_Code_ListListBox.Items);
            app.Enter_Epoching_CodeEditField.Visible = 'off';
            app.AddtriggercodeButton.Visible = 'off';
            app.CleartheListButton.Visible = 'off';
            app.DoneButton.Visible = 'off';
            app.TriggersEditField.Visible = 'on';
            app.Step7ElectrodesToRemoveLabel.Enable = 'on';
            app.Step7ElectrodesToRemoveLabel.Text = 'Wait...';
            drawnow

            Trigger_Temp = 'Trigger List: ';
            for  i = 1:length(app.Trigger_Code_ListListBox.Items)
                Trigger_Temp = cat(2,Trigger_Temp,' ', '{', app.Trigger_Code_ListListBox.Items{i}, '}')                                
            end
            app.TriggersEditField.Value = Trigger_Temp;


            app.Step2ResamplingRateLabel.BackgroundColor = [0.47,0.67,0.19];
            app.Step3FilterRangeLabel.BackgroundColor = [0.47,0.67,0.19];
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.BackgroundColor = [0.47,0.67,0.19];
            app.Step5EpochingMarginLabel.BackgroundColor = [0.47,0.67,0.19];
            app.Step6EpochingTriggerCodesLabel.BackgroundColor = [0.47,0.67,0.19];
            app.RightPanel.BackgroundColor = [0.502 0.502 0.502];
            app.Getting_Channel.Visible = 'on';
            app.GettingChannelInformationLabel.Visible = 'on';
            drawnow

            Resampling_Rate = app.ResamplingRateEditField.Value;
            Low_Cut = app.Low_CutEditField.Value;
            High_Cut = app.High_CutEditField.Value;
            Margin_MARA = app.NumberofMARAComponentsEditField.Value;
            Epoching_min = app.Epoching_minEditField.Value;
            Epoching_Max = app.Epoching_MaxEditField.Value;
            Subject = 1;
            [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
            Data_Address = app.File_Lists.Items;

            EEG = pop_loadcurry(Data_Address{1}, 'dataformat', 'auto', 'keystroke', 'on');
            Current_Study = erase(EEG.filename,'.dap');
            Current_Study =  regexprep(Current_Study, ' +', '_');

            app.GettingChannelInformationLabel.Visible = 'off';
            app.Getting_Channel.Visible = 'off';
            app.CurrentProcessingFileLabel.Text = 'Channel Lists';
            app.AddNonChanButton.Enable = 'on';
            app.NonChan_ListListBox.Visible = 'on';
            app.Step7ElectrodesToRemoveLabel.Text = 'Step7: Electrodes To Remove';
            Label_Col = find(contains(fieldnames(EEG.chanlocs),'label') == 1);
            Available_Channels = struct2cell(EEG.chanlocs);
            Available_Channels = squeeze(Available_Channels);
            Available_Channels = Available_Channels(Label_Col,:,:);
            Available_Channels=string(Available_Channels);
            Available_Channels = unique(Available_Channels);
            Available_Channels = cellstr(Available_Channels);
            app.NonChan_ListListBox.Items = Available_Channels;
        end

        % Button pushed function: AddNonChanButton
        function AddNonChanButtonPushed(app, event)
            app.RightPanel.BackgroundColor = [0.902 0.902 0.902];
            app.NonChan_ListListBox.Visible = 'off';
            app.AddNonChanButton.Visible = 'off';
            app.NonChanEditField.Visible = 'on';            
            NonChan_Temp = 'Removed Channels: ';
            for  i = 1:length(app.NonChan_ListListBox.Value)
                NonChan_Temp = cat(2,NonChan_Temp,' ', '{', app.NonChan_ListListBox.Value{i}, '}');                                
            end

            app.NonChanEditField.Value = NonChan_Temp;
            app.Step8ChoosetheoutputLabel.Enable = 'on';
            app.Step8ChoosetheoutputLabel.Enable = 'on';
            app.OutputButton.Enable = 'on';
            app.OutputSelectthefolderthatyouwanttosavedatainLabel.Enable = 'on';
            app.AddNonChanButton.Enable = 'off';
            app.Step7ElectrodesToRemoveLabel.BackgroundColor = [0.47,0.67,0.19];
            app.CurrentProcessingFileLabel.Text = 'Current Processing File';
        end

        % Button pushed function: StartButton_2
        function StartButton_2Pushed(app, event)
            app.RightPanel.BackgroundColor = [0.902 0.902 0.902];
            app.CenterPanel.BackgroundColor = [0.502 0.502 0.502];
            app.StartButton_2.Visible = 'off';
            Getting_File_Dir(app)
            app.BrowseButton.Visible = 'on';
            app.BrowseButton.Enable = 'on';
            app.Cover_Right_Panel.Visible = 'off';
        end

        % Value changed function: File_Lists
        function File_ListsValueChanged(app, event)
            value = app.File_Lists.Value;
            
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed2(app, event)
            app.File_Lists_2.Items = app.File_Lists.Value;
            app.File_Lists.Visible = 'off';
            app.BrowseButton.Visible = 'off';
            app.RightPanel.Enable = 'on';
            app.Step2ResamplingRateLabel.Enable = 'on';
            app.ResamplingRateEditField.Enable = 'on';
            app.ResamplingRateEditFieldLabel.Enable = 'on';
            app.Step3FilterRangeLabel.Enable = 'on';
            app.High_CutEditField.Enable = 'on';
            app.Low_CutEditField.Enable = 'on';
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.Enable = 'on';
            app.NumberofMARAComponentsEditField.Enable = 'on';
            app.Step5EpochingMarginLabel.Enable = 'on';
            app.secondsfromtheonsetofthetriggercodetoLabel.Enable = 'on';
            app.Epoching_MaxEditField.Enable = 'on';
            app.Epoching_minEditField.Enable = 'on';
            app.Step6EpochingTriggerCodesLabel.Enable = 'on';
            app.Enter_Epoching_CodeEditField.Enable = 'on';
            app.AddtriggercodeButton.Enable = 'on';
            app.CleartheListButton.Enable = 'on';
            app.DoneButton.Enable = 'on';
            app.Trigger_Code_ListListBox.Visible = 'on';
            app.CurrentProcessingFileLabel.Text = 'Trigger Codes';
            app.File_Lists_2.Visible = 'off';
            drawnow
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {569, 569, 569};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {569, 569};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {226, '1x', 440};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 867 569];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.UIFigure.Scrollable = 'on';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {226, '1x', 440};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.BackgroundColor = [0 0 0];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create Label
            app.Label = uilabel(app.LeftPanel);
            app.Label.HorizontalAlignment = 'center';
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 16;
            app.Label.FontWeight = 'bold';
            app.Label.FontAngle = 'italic';
            app.Label.FontColor = [1 1 1];
            app.Label.Position = [13 278 208 86];
            app.Label.Text = 'Pre-Processing Pipeline for Developmental Neurolinguisitcs Lab (DNL)';

            % Create Image
            app.Image = uiimage(app.LeftPanel);
            app.Image.Position = [7 396 213 172];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'DNL Logo Transparent.png');

            % Create Hyperlink
            app.Hyperlink = uihyperlink(app.LeftPanel);
            app.Hyperlink.FontColor = [0.9412 0.9412 0.9412];
            app.Hyperlink.URL = 'https://labs.utdallas.edu/brainlab';
            app.Hyperlink.Position = [21 264 193 22];
            app.Hyperlink.Text = 'https://labs.utdallas.edu/brainlab';

            % Create MinimumRequirementsLabel
            app.MinimumRequirementsLabel = uilabel(app.LeftPanel);
            app.MinimumRequirementsLabel.HorizontalAlignment = 'center';
            app.MinimumRequirementsLabel.FontWeight = 'bold';
            app.MinimumRequirementsLabel.FontColor = [1 1 1];
            app.MinimumRequirementsLabel.Position = [42 184 142 22];
            app.MinimumRequirementsLabel.Text = 'Minimum Requirements';

            % Create MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel
            app.MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel = uilabel(app.LeftPanel);
            app.MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel.WordWrap = 'on';
            app.MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel.FontSize = 11;
            app.MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel.FontColor = [1 1 1];
            app.MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel.Position = [6 7 208 198];
            app.MATLABR2017aorhigher2EEGLABPluginV14123EEGLABExtensionsLabel.Text = {'1. MATLAB R2022a or higher'; '2. EEGLAB Plugin V 2023'; '3. EEGLAB Extensions'; '       MARA1.2'; '       loadcurry2.0'; '       Neuroelectrics EEGLab-Plugin-master'; '       clean_rawdata2.7'; '       Biosig3.8.1'; '       firfilt1.6.2'; ''};

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.BackgroundColor = [0 0 0];
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create CurrentProcessingFileLabel
            app.CurrentProcessingFileLabel = uilabel(app.CenterPanel);
            app.CurrentProcessingFileLabel.BackgroundColor = [0 0 0];
            app.CurrentProcessingFileLabel.HorizontalAlignment = 'center';
            app.CurrentProcessingFileLabel.FontWeight = 'bold';
            app.CurrentProcessingFileLabel.FontColor = [1 1 1];
            app.CurrentProcessingFileLabel.Position = [7 532 189 30];
            app.CurrentProcessingFileLabel.Text = 'Current Processing File';

            % Create Current_StudyEditField
            app.Current_StudyEditField = uieditfield(app.CenterPanel, 'text');
            app.Current_StudyEditField.Editable = 'off';
            app.Current_StudyEditField.HorizontalAlignment = 'center';
            app.Current_StudyEditField.FontWeight = 'bold';
            app.Current_StudyEditField.BackgroundColor = [0.902 0.902 0.902];
            app.Current_StudyEditField.Position = [20 500 163 27];
            app.Current_StudyEditField.Value = 'None';

            % Create NumberofFilesPreProcessedLabel
            app.NumberofFilesPreProcessedLabel = uilabel(app.CenterPanel);
            app.NumberofFilesPreProcessedLabel.BackgroundColor = [0 0 0];
            app.NumberofFilesPreProcessedLabel.HorizontalAlignment = 'center';
            app.NumberofFilesPreProcessedLabel.FontSize = 11;
            app.NumberofFilesPreProcessedLabel.FontWeight = 'bold';
            app.NumberofFilesPreProcessedLabel.FontColor = [1 1 1];
            app.NumberofFilesPreProcessedLabel.Position = [12 463 175 30];
            app.NumberofFilesPreProcessedLabel.Text = 'Number of Files Pre-Processed';

            % Create Number_DoneEditField
            app.Number_DoneEditField = uieditfield(app.CenterPanel, 'text');
            app.Number_DoneEditField.HorizontalAlignment = 'center';
            app.Number_DoneEditField.FontWeight = 'bold';
            app.Number_DoneEditField.BackgroundColor = [0.8 0.8 0.8];
            app.Number_DoneEditField.Position = [16 431 166 28];
            app.Number_DoneEditField.Value = 'N/A out of N/A';

            % Create ProgressLabel
            app.ProgressLabel = uilabel(app.CenterPanel);
            app.ProgressLabel.BackgroundColor = [0 0 0];
            app.ProgressLabel.HorizontalAlignment = 'center';
            app.ProgressLabel.FontWeight = 'bold';
            app.ProgressLabel.FontColor = [1 1 1];
            app.ProgressLabel.Position = [16 396 169 29];
            app.ProgressLabel.Text = 'Progress...';

            % Create ResamplingEditField
            app.ResamplingEditField = uieditfield(app.CenterPanel, 'text');
            app.ResamplingEditField.FontSize = 11;
            app.ResamplingEditField.FontWeight = 'bold';
            app.ResamplingEditField.BackgroundColor = [0.502 0.502 0.502];
            app.ResamplingEditField.Enable = 'off';
            app.ResamplingEditField.Position = [9 364 82 20];
            app.ResamplingEditField.Value = 'Resampling';

            % Create Resampling_Queue
            app.Resampling_Queue = uiimage(app.CenterPanel);
            app.Resampling_Queue.Enable = 'off';
            app.Resampling_Queue.Position = [170 364 24 20];
            app.Resampling_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create HPFilter_Queue
            app.HPFilter_Queue = uiimage(app.CenterPanel);
            app.HPFilter_Queue.Enable = 'off';
            app.HPFilter_Queue.Position = [170 335 24 20];
            app.HPFilter_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create HPFilterEditField
            app.HPFilterEditField = uieditfield(app.CenterPanel, 'text');
            app.HPFilterEditField.FontSize = 11;
            app.HPFilterEditField.FontWeight = 'bold';
            app.HPFilterEditField.BackgroundColor = [0.502 0.502 0.502];
            app.HPFilterEditField.Enable = 'off';
            app.HPFilterEditField.Position = [9 335 94 20];
            app.HPFilterEditField.Value = 'High Pass Filter';

            % Create LPFilterEditField
            app.LPFilterEditField = uieditfield(app.CenterPanel, 'text');
            app.LPFilterEditField.FontSize = 11;
            app.LPFilterEditField.FontWeight = 'bold';
            app.LPFilterEditField.BackgroundColor = [0.502 0.502 0.502];
            app.LPFilterEditField.Enable = 'off';
            app.LPFilterEditField.Position = [9 305 132 20];
            app.LPFilterEditField.Value = 'Low Pass Filter';

            % Create LPFilter_Queue
            app.LPFilter_Queue = uiimage(app.CenterPanel);
            app.LPFilter_Queue.Enable = 'off';
            app.LPFilter_Queue.Position = [170 305 24 20];
            app.LPFilter_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create clean_rawdata_Queue
            app.clean_rawdata_Queue = uiimage(app.CenterPanel);
            app.clean_rawdata_Queue.Enable = 'off';
            app.clean_rawdata_Queue.Position = [171 278 24 20];
            app.clean_rawdata_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create clean_rawdataEditField
            app.clean_rawdataEditField = uieditfield(app.CenterPanel, 'text');
            app.clean_rawdataEditField.FontSize = 11;
            app.clean_rawdataEditField.FontWeight = 'bold';
            app.clean_rawdataEditField.BackgroundColor = [0.502 0.502 0.502];
            app.clean_rawdataEditField.Enable = 'off';
            app.clean_rawdataEditField.Position = [8 278 94 20];
            app.clean_rawdataEditField.Value = 'clean_rawdata';

            % Create Save_preproc_Queue
            app.Save_preproc_Queue = uiimage(app.CenterPanel);
            app.Save_preproc_Queue.Enable = 'off';
            app.Save_preproc_Queue.Position = [172 252 24 20];
            app.Save_preproc_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create Save_preprocEditField
            app.Save_preprocEditField = uieditfield(app.CenterPanel, 'text');
            app.Save_preprocEditField.FontSize = 11;
            app.Save_preprocEditField.FontWeight = 'bold';
            app.Save_preprocEditField.BackgroundColor = [0.502 0.502 0.502];
            app.Save_preprocEditField.Enable = 'off';
            app.Save_preprocEditField.Position = [9 252 115 20];
            app.Save_preprocEditField.Value = 'Save _preproc.set';

            % Create ChanLoc_Queue
            app.ChanLoc_Queue = uiimage(app.CenterPanel);
            app.ChanLoc_Queue.Enable = 'off';
            app.ChanLoc_Queue.Position = [170 224 24 20];
            app.ChanLoc_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create ChanLocEditField
            app.ChanLocEditField = uieditfield(app.CenterPanel, 'text');
            app.ChanLocEditField.FontSize = 11;
            app.ChanLocEditField.FontWeight = 'bold';
            app.ChanLocEditField.BackgroundColor = [0.502 0.502 0.502];
            app.ChanLocEditField.Enable = 'off';
            app.ChanLocEditField.Position = [9 224 149 20];
            app.ChanLocEditField.Value = 'Loading Channel Location';

            % Create ICA_Queue
            app.ICA_Queue = uiimage(app.CenterPanel);
            app.ICA_Queue.Enable = 'off';
            app.ICA_Queue.Position = [171 193 24 20];
            app.ICA_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create ICAEditField
            app.ICAEditField = uieditfield(app.CenterPanel, 'text');
            app.ICAEditField.FontSize = 11;
            app.ICAEditField.FontWeight = 'bold';
            app.ICAEditField.BackgroundColor = [0.502 0.502 0.502];
            app.ICAEditField.Enable = 'off';
            app.ICAEditField.Position = [10 193 82 20];
            app.ICAEditField.Value = 'ICA';

            % Create MARA_Queue
            app.MARA_Queue = uiimage(app.CenterPanel);
            app.MARA_Queue.Enable = 'off';
            app.MARA_Queue.Position = [170 164 24 20];
            app.MARA_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create MARAEditField
            app.MARAEditField = uieditfield(app.CenterPanel, 'text');
            app.MARAEditField.FontSize = 11;
            app.MARAEditField.FontWeight = 'bold';
            app.MARAEditField.BackgroundColor = [0.502 0.502 0.502];
            app.MARAEditField.Enable = 'off';
            app.MARAEditField.Position = [9 164 82 20];
            app.MARAEditField.Value = 'MARA';

            % Create AveRef_Queue
            app.AveRef_Queue = uiimage(app.CenterPanel);
            app.AveRef_Queue.Enable = 'off';
            app.AveRef_Queue.Position = [170 134 24 20];
            app.AveRef_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create AveRefEditField
            app.AveRefEditField = uieditfield(app.CenterPanel, 'text');
            app.AveRefEditField.FontSize = 11;
            app.AveRefEditField.FontWeight = 'bold';
            app.AveRefEditField.BackgroundColor = [0.502 0.502 0.502];
            app.AveRefEditField.Enable = 'off';
            app.AveRefEditField.Position = [9 134 133 20];
            app.AveRefEditField.Value = 'Average Rereferencing';

            % Create Epoching_Queue
            app.Epoching_Queue = uiimage(app.CenterPanel);
            app.Epoching_Queue.Enable = 'off';
            app.Epoching_Queue.Position = [170 105 24 20];
            app.Epoching_Queue.ImageSource = fullfile(pathToMLAPP, 'Queue.png');

            % Create EpochingEditField
            app.EpochingEditField = uieditfield(app.CenterPanel, 'text');
            app.EpochingEditField.FontSize = 11;
            app.EpochingEditField.FontWeight = 'bold';
            app.EpochingEditField.BackgroundColor = [0.502 0.502 0.502];
            app.EpochingEditField.Enable = 'off';
            app.EpochingEditField.Position = [9 105 82 20];
            app.EpochingEditField.Value = 'Epoching';

            % Create Trigger_Code_ListListBox
            app.Trigger_Code_ListListBox = uilistbox(app.CenterPanel);
            app.Trigger_Code_ListListBox.Items = {};
            app.Trigger_Code_ListListBox.Multiselect = 'on';
            app.Trigger_Code_ListListBox.ValueChangedFcn = createCallbackFcn(app, @Trigger_Code_ListListBoxValueChanged, true);
            app.Trigger_Code_ListListBox.Visible = 'off';
            app.Trigger_Code_ListListBox.Position = [6 6 190 521];
            app.Trigger_Code_ListListBox.Value = {};

            % Create NonChan_ListListBox
            app.NonChan_ListListBox = uilistbox(app.CenterPanel);
            app.NonChan_ListListBox.Items = {};
            app.NonChan_ListListBox.Multiselect = 'on';
            app.NonChan_ListListBox.Visible = 'off';
            app.NonChan_ListListBox.Position = [7 7 190 520];
            app.NonChan_ListListBox.Value = {};

            % Create File_Lists_2
            app.File_Lists_2 = uilistbox(app.CenterPanel);
            app.File_Lists_2.Items = {};
            app.File_Lists_2.Multiselect = 'on';
            app.File_Lists_2.FontColor = [1 1 1];
            app.File_Lists_2.BackgroundColor = [0 0 0];
            app.File_Lists_2.Position = [1 6 194 557];
            app.File_Lists_2.Value = {};

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BackgroundColor = [0 0 0];
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create ResamplingRateEditFieldLabel
            app.ResamplingRateEditFieldLabel = uilabel(app.RightPanel);
            app.ResamplingRateEditFieldLabel.HorizontalAlignment = 'right';
            app.ResamplingRateEditFieldLabel.Enable = 'off';
            app.ResamplingRateEditFieldLabel.Position = [11 515 95 22];
            app.ResamplingRateEditFieldLabel.Text = 'Resampling Rate';

            % Create ResamplingRateEditField
            app.ResamplingRateEditField = uieditfield(app.RightPanel, 'numeric');
            app.ResamplingRateEditField.Limits = [2 1000];
            app.ResamplingRateEditField.Enable = 'off';
            app.ResamplingRateEditField.Tooltip = {'Enter Resampling Rate'};
            app.ResamplingRateEditField.Position = [322 515 96 22];
            app.ResamplingRateEditField.Value = 512;

            % Create High_CutEditFieldLabel
            app.High_CutEditFieldLabel = uilabel(app.RightPanel);
            app.High_CutEditFieldLabel.HorizontalAlignment = 'right';
            app.High_CutEditFieldLabel.Enable = 'off';
            app.High_CutEditFieldLabel.Position = [247 456 56 22];
            app.High_CutEditFieldLabel.Text = 'High_Cut';

            % Create High_CutEditField
            app.High_CutEditField = uieditfield(app.RightPanel, 'numeric');
            app.High_CutEditField.Limits = [0 512];
            app.High_CutEditField.Enable = 'off';
            app.High_CutEditField.Tooltip = {'Enter the bandpass for the lowpass filter  (e.g. 100 to have the gamma activity)'};
            app.High_CutEditField.Position = [319 456 100 22];
            app.High_CutEditField.Value = 100;

            % Create Button
            app.Button = uibutton(app.RightPanel, 'push');
            app.Button.Position = [1 566 2 2];

            % Create Step3FilterRangeLabel
            app.Step3FilterRangeLabel = uilabel(app.RightPanel);
            app.Step3FilterRangeLabel.BackgroundColor = [0 0 0];
            app.Step3FilterRangeLabel.HorizontalAlignment = 'center';
            app.Step3FilterRangeLabel.FontWeight = 'bold';
            app.Step3FilterRangeLabel.FontColor = [1 1 1];
            app.Step3FilterRangeLabel.Enable = 'off';
            app.Step3FilterRangeLabel.Position = [6 483 424 22];
            app.Step3FilterRangeLabel.Text = 'Step3: Filter Range';

            % Create Step5EpochingMarginLabel
            app.Step5EpochingMarginLabel = uilabel(app.RightPanel);
            app.Step5EpochingMarginLabel.BackgroundColor = [0 0 0];
            app.Step5EpochingMarginLabel.HorizontalAlignment = 'center';
            app.Step5EpochingMarginLabel.FontWeight = 'bold';
            app.Step5EpochingMarginLabel.FontColor = [1 1 1];
            app.Step5EpochingMarginLabel.Enable = 'off';
            app.Step5EpochingMarginLabel.Tooltip = {'Enter the number of components that you want to be kept by MARA artifact rejection'};
            app.Step5EpochingMarginLabel.Position = [6 363 424 22];
            app.Step5EpochingMarginLabel.Text = 'Step5: Epoching Margin';

            % Create Low_CutEditFieldLabel
            app.Low_CutEditFieldLabel = uilabel(app.RightPanel);
            app.Low_CutEditFieldLabel.HorizontalAlignment = 'right';
            app.Low_CutEditFieldLabel.Enable = 'off';
            app.Low_CutEditFieldLabel.Position = [11 454 53 22];
            app.Low_CutEditFieldLabel.Text = 'Low_Cut';

            % Create Low_CutEditField
            app.Low_CutEditField = uieditfield(app.RightPanel, 'numeric');
            app.Low_CutEditField.Limits = [0 512];
            app.Low_CutEditField.Enable = 'off';
            app.Low_CutEditField.Tooltip = {'Enter the bandpass for the highpass filter  (e.g. 0.1 to have the delta activity)'};
            app.Low_CutEditField.Position = [88 454 100 22];
            app.Low_CutEditField.Value = 0.1;

            % Create NumberofMARAComponentsEditFieldLabel
            app.NumberofMARAComponentsEditFieldLabel = uilabel(app.RightPanel);
            app.NumberofMARAComponentsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofMARAComponentsEditFieldLabel.Enable = 'off';
            app.NumberofMARAComponentsEditFieldLabel.Position = [14 395 171 22];
            app.NumberofMARAComponentsEditFieldLabel.Text = 'Number of MARA Components';

            % Create NumberofMARAComponentsEditField
            app.NumberofMARAComponentsEditField = uieditfield(app.RightPanel, 'numeric');
            app.NumberofMARAComponentsEditField.Limits = [0 100];
            app.NumberofMARAComponentsEditField.Enable = 'off';
            app.NumberofMARAComponentsEditField.Tooltip = {'Number of components that you want to be kept by MARA artifact rejection'};
            app.NumberofMARAComponentsEditField.Position = [319 395 100 22];
            app.NumberofMARAComponentsEditField.Value = 20;

            % Create Epoching_minEditField
            app.Epoching_minEditField = uieditfield(app.RightPanel, 'numeric');
            app.Epoching_minEditField.Limits = [-6000 0];
            app.Epoching_minEditField.HorizontalAlignment = 'center';
            app.Epoching_minEditField.Enable = 'off';
            app.Epoching_minEditField.Tooltip = {'The starting time point from the onset of the trigger code (e.g. to start the epochs from -500 msec before the trigger code -> -0.5) '};
            app.Epoching_minEditField.Position = [11 334 69 22];
            app.Epoching_minEditField.Value = -0.5;

            % Create Epoching_MaxEditField
            app.Epoching_MaxEditField = uieditfield(app.RightPanel, 'numeric');
            app.Epoching_MaxEditField.Limits = [0 100001];
            app.Epoching_MaxEditField.HorizontalAlignment = 'center';
            app.Epoching_MaxEditField.Enable = 'off';
            app.Epoching_MaxEditField.Tooltip = {'The end time point from the onset of the trigger code (e.g. to end the epochs at 9600 msec before the trigger code -> 9.6) '};
            app.Epoching_MaxEditField.Position = [348 336 71 22];
            app.Epoching_MaxEditField.Value = 6.9;

            % Create secondsfromtheonsetofthetriggercodetoLabel
            app.secondsfromtheonsetofthetriggercodetoLabel = uilabel(app.RightPanel);
            app.secondsfromtheonsetofthetriggercodetoLabel.Enable = 'off';
            app.secondsfromtheonsetofthetriggercodetoLabel.Position = [95 335 246 22];
            app.secondsfromtheonsetofthetriggercodetoLabel.Text = 'seconds from the onset of the trigger code to';

            % Create Step6EpochingTriggerCodesLabel
            app.Step6EpochingTriggerCodesLabel = uilabel(app.RightPanel);
            app.Step6EpochingTriggerCodesLabel.BackgroundColor = [0 0 0];
            app.Step6EpochingTriggerCodesLabel.HorizontalAlignment = 'center';
            app.Step6EpochingTriggerCodesLabel.FontWeight = 'bold';
            app.Step6EpochingTriggerCodesLabel.FontColor = [1 1 1];
            app.Step6EpochingTriggerCodesLabel.Enable = 'off';
            app.Step6EpochingTriggerCodesLabel.Position = [6 304 424 22];
            app.Step6EpochingTriggerCodesLabel.Text = 'Step6: Epoching Trigger Codes';

            % Create OutputButton
            app.OutputButton = uibutton(app.RightPanel, 'push');
            app.OutputButton.ButtonPushedFcn = createCallbackFcn(app, @OutputButtonPushed, true);
            app.OutputButton.Enable = 'off';
            app.OutputButton.Position = [323 159 100 22];
            app.OutputButton.Text = 'Browse';

            % Create OutputSelectthefolderthatyouwanttosavedatainLabel
            app.OutputSelectthefolderthatyouwanttosavedatainLabel = uilabel(app.RightPanel);
            app.OutputSelectthefolderthatyouwanttosavedatainLabel.Enable = 'off';
            app.OutputSelectthefolderthatyouwanttosavedatainLabel.Position = [10 158 295 22];
            app.OutputSelectthefolderthatyouwanttosavedatainLabel.Text = 'Output: Select the folder that you want to save data in';

            % Create Output_FileEditField
            app.Output_FileEditField = uieditfield(app.RightPanel, 'text');
            app.Output_FileEditField.Editable = 'off';
            app.Output_FileEditField.Enable = 'off';
            app.Output_FileEditField.Position = [7 130 406 22];
            app.Output_FileEditField.Value = 'No Folder Selected';

            % Create Step2ResamplingRateLabel
            app.Step2ResamplingRateLabel = uilabel(app.RightPanel);
            app.Step2ResamplingRateLabel.BackgroundColor = [0 0 0];
            app.Step2ResamplingRateLabel.HorizontalAlignment = 'center';
            app.Step2ResamplingRateLabel.FontWeight = 'bold';
            app.Step2ResamplingRateLabel.FontColor = [1 1 1];
            app.Step2ResamplingRateLabel.Enable = 'off';
            app.Step2ResamplingRateLabel.Position = [8 541 424 22];
            app.Step2ResamplingRateLabel.Text = 'Step2: Resampling Rate';

            % Create Step4ChoosethenumberofICAcomponentsremovedbyMARALabel
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel = uilabel(app.RightPanel);
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.BackgroundColor = [0 0 0];
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.HorizontalAlignment = 'center';
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.FontWeight = 'bold';
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.FontColor = [1 1 1];
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.Enable = 'off';
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.Position = [6 421 424 22];
            app.Step4ChoosethenumberofICAcomponentsremovedbyMARALabel.Text = 'Step4: Choose the number of ICA components removed by MARA';

            % Create Step8ChoosetheoutputLabel
            app.Step8ChoosetheoutputLabel = uilabel(app.RightPanel);
            app.Step8ChoosetheoutputLabel.BackgroundColor = [0 0 0];
            app.Step8ChoosetheoutputLabel.HorizontalAlignment = 'center';
            app.Step8ChoosetheoutputLabel.FontWeight = 'bold';
            app.Step8ChoosetheoutputLabel.FontColor = [1 1 1];
            app.Step8ChoosetheoutputLabel.Enable = 'off';
            app.Step8ChoosetheoutputLabel.Position = [7 186 423 22];
            app.Step8ChoosetheoutputLabel.Text = 'Step8: Choose the output';

            % Create Step7ElectrodesToRemoveLabel
            app.Step7ElectrodesToRemoveLabel = uilabel(app.RightPanel);
            app.Step7ElectrodesToRemoveLabel.BackgroundColor = [0 0 0];
            app.Step7ElectrodesToRemoveLabel.HorizontalAlignment = 'center';
            app.Step7ElectrodesToRemoveLabel.FontWeight = 'bold';
            app.Step7ElectrodesToRemoveLabel.FontColor = [1 1 1];
            app.Step7ElectrodesToRemoveLabel.Enable = 'off';
            app.Step7ElectrodesToRemoveLabel.Position = [6 245 424 22];
            app.Step7ElectrodesToRemoveLabel.Text = 'Step7: Electrodes To Remove';

            % Create StartButton
            app.StartButton = uibutton(app.RightPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Enable = 'off';
            app.StartButton.Position = [166 88 100 22];
            app.StartButton.Text = 'Start';

            % Create Enter_Epoching_CodeEditField
            app.Enter_Epoching_CodeEditField = uieditfield(app.RightPanel, 'text');
            app.Enter_Epoching_CodeEditField.Enable = 'off';
            app.Enter_Epoching_CodeEditField.Tooltip = {'Enter the epoching trigger code ONE BY ONE (e.g. ''141''  ''143''  ''145'' for Real Word Auditory Task)'};
            app.Enter_Epoching_CodeEditField.Placeholder = 'Type one trigger code';
            app.Enter_Epoching_CodeEditField.Position = [13 276 130 22];

            % Create AddtriggercodeButton
            app.AddtriggercodeButton = uibutton(app.RightPanel, 'push');
            app.AddtriggercodeButton.ButtonPushedFcn = createCallbackFcn(app, @AddtriggercodeButtonPushed, true);
            app.AddtriggercodeButton.Enable = 'off';
            app.AddtriggercodeButton.Position = [153 276 99 22];
            app.AddtriggercodeButton.Text = 'Add trigger code';

            % Create CleartheListButton
            app.CleartheListButton = uibutton(app.RightPanel, 'push');
            app.CleartheListButton.ButtonPushedFcn = createCallbackFcn(app, @CleartheListButtonPushed, true);
            app.CleartheListButton.Enable = 'off';
            app.CleartheListButton.Position = [258 276 100 22];
            app.CleartheListButton.Text = 'Clear the List';

            % Create DoneButton
            app.DoneButton = uibutton(app.RightPanel, 'push');
            app.DoneButton.ButtonPushedFcn = createCallbackFcn(app, @DoneButtonPushed, true);
            app.DoneButton.Enable = 'off';
            app.DoneButton.Position = [361 276 66 22];
            app.DoneButton.Text = 'Done';

            % Create TriggersEditField
            app.TriggersEditField = uieditfield(app.RightPanel, 'text');
            app.TriggersEditField.Enable = 'off';
            app.TriggersEditField.Visible = 'off';
            app.TriggersEditField.Placeholder = 'N/A';
            app.TriggersEditField.Position = [10 276 416 22];

            % Create AddNonChanButton
            app.AddNonChanButton = uibutton(app.RightPanel, 'push');
            app.AddNonChanButton.ButtonPushedFcn = createCallbackFcn(app, @AddNonChanButtonPushed, true);
            app.AddNonChanButton.Enable = 'off';
            app.AddNonChanButton.Tooltip = {'Select the Channels that you want to be removed in pre-processing, to select multiple hold ctrl button and choose all you want (e.g. VOE, HOE)'};
            app.AddNonChanButton.Position = [17 216 407 22];
            app.AddNonChanButton.Text = 'Press To Remove';

            % Create NonChanEditField
            app.NonChanEditField = uieditfield(app.RightPanel, 'text');
            app.NonChanEditField.Enable = 'off';
            app.NonChanEditField.Visible = 'off';
            app.NonChanEditField.Placeholder = 'N/A';
            app.NonChanEditField.Position = [11 216 416 22];

            % Create StartButton_2
            app.StartButton_2 = uibutton(app.RightPanel, 'push');
            app.StartButton_2.ButtonPushedFcn = createCallbackFcn(app, @StartButton_2Pushed, true);
            app.StartButton_2.WordWrap = 'on';
            app.StartButton_2.FontSize = 18;
            app.StartButton_2.FontWeight = 'bold';
            app.StartButton_2.Position = [155 7 126 31];
            app.StartButton_2.Text = 'Start';

            % Create GettingChannelInformationLabel
            app.GettingChannelInformationLabel = uilabel(app.RightPanel);
            app.GettingChannelInformationLabel.BackgroundColor = [0.502 0.502 0.502];
            app.GettingChannelInformationLabel.HorizontalAlignment = 'center';
            app.GettingChannelInformationLabel.FontSize = 24;
            app.GettingChannelInformationLabel.FontWeight = 'bold';
            app.GettingChannelInformationLabel.Visible = 'off';
            app.GettingChannelInformationLabel.Position = [2 26 432 179];
            app.GettingChannelInformationLabel.Text = 'Getting Channel Information';

            % Create Getting_Channel
            app.Getting_Channel = uiimage(app.RightPanel);
            app.Getting_Channel.Visible = 'off';
            app.Getting_Channel.BackgroundColor = [0.502 0.502 0.502];
            app.Getting_Channel.Position = [6 180 428 383];
            app.Getting_Channel.ImageSource = fullfile(pathToMLAPP, 'In_Progress.gif');

            % Create File_Lists
            app.File_Lists = uilistbox(app.RightPanel);
            app.File_Lists.Items = {};
            app.File_Lists.Multiselect = 'on';
            app.File_Lists.ValueChangedFcn = createCallbackFcn(app, @File_ListsValueChanged, true);
            app.File_Lists.FontColor = [1 1 1];
            app.File_Lists.BackgroundColor = [0 0 0];
            app.File_Lists.Position = [7 55 427 507];
            app.File_Lists.Value = {};

            % Create BrowseButton
            app.BrowseButton = uibutton(app.RightPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed2, true);
            app.BrowseButton.WordWrap = 'on';
            app.BrowseButton.FontSize = 18;
            app.BrowseButton.FontWeight = 'bold';
            app.BrowseButton.Enable = 'off';
            app.BrowseButton.Visible = 'off';
            app.BrowseButton.Position = [288 7 126 31];
            app.BrowseButton.Text = 'Browse';

            % Create Source_Directory
            app.Source_Directory = uilistbox(app.RightPanel);
            app.Source_Directory.Items = {};
            app.Source_Directory.Enable = 'off';
            app.Source_Directory.Visible = 'off';
            app.Source_Directory.FontColor = [1 1 1];
            app.Source_Directory.BackgroundColor = [0 0 0];
            app.Source_Directory.Position = [7 532 427 27];
            app.Source_Directory.Value = {};

            % Create Cover_Right_Panel
            app.Cover_Right_Panel = uilabel(app.RightPanel);
            app.Cover_Right_Panel.HorizontalAlignment = 'center';
            app.Cover_Right_Panel.WordWrap = 'on';
            app.Cover_Right_Panel.FontSize = 48;
            app.Cover_Right_Panel.FontColor = [1 1 1];
            app.Cover_Right_Panel.Position = [4 88 431 474];
            app.Cover_Right_Panel.Text = 'Press Start and Select the Folder that has EEG files to pre-process';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Pre_Processing_App_092224

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
