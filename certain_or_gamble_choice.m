%% Multi-arm Bandit: Choosing a certain or gambling %%
clear all; clc; close all;
addpath(genpath('C:\script\'))
addpath(genpath('C:\Users\SAMSUNG\Desktop'));
sub = input('SubjectID: ');

path = 'C:\Users\SAMSUNG\Desktop\Matlab_exercise';
data_file_path  = [path 'sub' num2str(sub)];
[~, msg, ~] = mkdir(data_file_path);
researcher_specify = input(['\n\n' ...
            'Please type the first name of the researcher conducting the study?' '\n' ...
            'Make sure to capitalize your name (e.g. Alex not alex)' '\n' ...
            'Name: ' ], 's');

 %mNtrls = input(['How many trials in the maths experiment? ']);
%Ntrl = 60; Nblk = 4;
Ntrl = 6;
runn = input('Type run number: ');

%% parameter settings %%
Nrun = 4; eidx = Ntrl*runn; bidx = (Ntrl*(runn-1))+1;
init.runn = runn;
init.researcher = researcher_specify;
init.data_file_path = data_file_path;
init.sub = sub;
init.txtsize1 = 60;init.txtsize2 = 70;
init.iti = 2; init.task_time = 3; init.present_time = 6; init.result_time = 1; init.ask_prob = 4;
init.total_time = init.iti + init.task_time + init.present_time + init.result_time + init.iti + init.ask_prob;
        
%% experiment %%
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 1);
FlushEvents;
PsychDefaultSetup(1);

% Screen set up %
screens = Screen('Screens'); 
whichScreen = max(screens); 
black = BlackIndex(whichScreen); white = WhiteIndex(whichScreen);
init.txtsize1 = 60;

%[w, rect] = Screen('OpenWindow', whichScreen, black);
[w, rect] = Screen('OpenWindow', whichScreen, black, [0 0 1920 900]);
Screen('TextSize', w, init.txtsize1);

% bar presentation %
init.bar_width = 5;
init.bar_length = rect(3)/2;
init.bar_height = 30;
init.vbar_length = 5;
init.vbar_width = rect(4)*(2/3);
init.hbar_width = 5;
init.hbar_length = rect(3)*(2/3);
init.scale_range = [0 10];
init.jump_step = init.scale_range(2)-init.scale_range(1);
init.move_step = floor(init.bar_length/init.jump_step);
init.bar_loc = [0 0 rect(3)*0.5 rect(4)*0.7];

% keyboard setup %
KbName('UnifyKeyNames');
syncNum = KbName('s');
L = KbName('LeftArrow'); R = KbName('RightArrow');
spaceKey = KbName('Space');

fliprate = Screen(w, 'GetFlipInterval');
keys = [L R spaceKey]; init.keys = keys;

%% define screen grid %%  자극 및 문자의 위치를 설정하기 위해 화면의 그리드를 정의하는 것 
dim1 = 4; dim2 = 10; %5행 10열 
loc_param1 = linspace(0,1,dim1+2); %화면의 가장 위쪽을 0으로 두고 화면의 아래쪽까지 1의 단위로 7개로 나눠라 
loc_param1 = loc_param1(2:dim1+1); % 화면의 2행부터 5행까지 추출 (끝 공간을 배제하기 위해)
loc_param2 = linspace(0,1,dim2+2); 
loc_param2 = loc_param2(2:dim2+1); % 화면의 2열부터 10열까지 추출 

for d1 = 1:dim1 %d1은 1~5까지 
    for d2 = 1:dim2 %d2는 1~10까지 
        cmat4(d1,d2) = loc_param1(d1); %화면의 2행부터 5행까지 사용해라;화면의 세로 영역 분할 
        cmat3(d1,d2) = loc_param2(d2);%화면을 2열부터 10열까지 사용해라;화면의 가로 영역 분할 
    end
end

r = [0,0,400,300]; %stimuli rectangle
fracLoc{1} = CenterRectOnPoint(r, rect(3)*0.3, rect(4)*0.5);
fracLoc{2} = CenterRectOnPoint(r, rect(3)*0.7, rect(4)*0.3);
fracLoc{3} = CenterRectOnPoint(r, rect(3)*0.7, rect(4)*0.7);

valLoc{1} = [rect(3)*0.285, rect(4)*0.52];
valLoc{2} = [rect(3)*0.675, rect(4)*0.33];
valLoc{3} = [rect(3)*0.675, rect(4)*0.72];

%% Draw Stimuli %%
Screen('TextSize', w, init.txtsize1);
Screen('TextFont', w, 'Malgun Gothic');
DrawFormattedText(w, '+', 'center', 'center', white); 
Screen('Flip', w); WaitSecs(2); task.score = 0;

Nconds = 3; condN = Ntrl/Nconds;
conditions = [ones(condN,1);ones(condN,1).*2; ones(condN,1).*3];
conditions = conditions(randperm(Ntrl));

task.onffset = NaN(Ntrl,2); task.rt = NaN(Ntrl,6); 
task.position = NaN(Ntrl,2); task.result = NaN(Ntrl,1); task.payoff_det = rand(Ntrl,3);
task.condition = NaN(Ntrl,3,3); task.certain_choice = NaN(Ntrl,1);
task.gamble_choice = NaN(Ntrl,2);

%a = [];
%for i = 1:50; a(i) = rand(1); end   predefine 하는 방법 
for trl = 1:Ntrl
    if trl > 1; disp(['trl ' num2str(trl) ':: ', num2str(task.onffset(trl-1,end)-task.onffset(trl-1,1)) 's']); end
    stim_time = GetSecs; task.onffset(trl,1) = stim_time;
    Screen('TextSize', w, init.txtsize1);
    Screen('TextFont', w, 'Malgun Gothic');
    DrawFormattedText(w, '+', 'center', 'center', white);    
    Screen(w,'Flip');    
   
    %% Values %%
    certain1 = [0]; %mix_certain  
    certain2 = [20, 30, 40, 50, 60]; %gain_certain
    certain3 = [-20, -30, -40, -50, -60]; %loss_certain
    certain = [0 certain2(randi(5)) certain3(randi(5))];
    

    mix_gain = [30 50 80 110 150];
    mix_multi = [0.2, 0.3, 0.4, 0.52, 0.66, 0.82, 1, 1.2, 1.5, 2]; 
    mix_loss = mix_gain' * mix_multi; mix_loss=mix_loss(:);
    gainORloss_multi = [1.68, 1.82, 2, 2.22, 2.48,2.8, 3.16, 3.6, 4.2, 5];
    gain_gain = certain2' * gainORloss_multi; gain_gain = gain_gain(:);
    loss_loss = certain3' * gainORloss_multi; loss_loss=loss_loss(:);

    random1 = [-mix_loss(randi(50)), mix_gain(randi(5))]; %mix_
    random2 = [0, gain_gain(randi(50))]; %gain_
    random3 = [0,loss_loss(randi(50))]; %loss_
    random = [random1 random2 random3];
    random = reshape(random, 2,3)

    result1 = random1(randi(2)); %mix
    result2 = random2(randi(2)); %gain
    result3 = random3(randi(2)); %loss

     %% present stimuli %%
    t = conditions(trl);
    Screen('TextSize', w, init.txtsize2);
    Screen('TextFont', w, 'Malgun Gothic');
    DrawFormattedText(w, '+', 'center', 'center', white); 
    Screen('FillRect',w,white, fracLoc{1});
    DrawFormattedText(w, num2str(certain(t)), valLoc{1}(1), valLoc{1}(2), black); %DrawFormattedtext 함수 특성상 volLoc{}을 두번 나눠 써야해
    task.condition(trl,t,:) = certain(t); %certain 값 저장 
    
    for p = 1:2 
        textx = random(p,t);
        Screen('FillRect',w,white, fracLoc{p+1});
        DrawFormattedText(w, num2str(textx), valLoc{p+1}(1), valLoc{p+1}(2), black);
        task.position(trl,p) = textx; % 매 trl마다 task.position에 gamble값 저장 
    end

    while GetSecs - task.onffset(trl,1) < init.iti; end %3초동안보여주기 
    Screen(w, 'Flip'); %위 코딩을 화면에 출력 
    
    %%  record a response %%
    start_time = GetSecs; task.rt(trl,1) = start_time; selection = [];
    while ( GetSecs - start_time ) < init.task_time
        [keyisdown,secs,keycode]=KbCheck;
        if keyisdown 
            if keycode(keys(1))
                selection = keys(1);
                task.rt(trl,2) = GetSecs; task.rt(trl,3) = task.rt(trl,2)-task.rt(trl,1); break;
            elseif keycode(keys(2))
                selection = keys(2);
                task.rt(trl,2) = GetSecs; task.rt(trl,3) = task.rt(trl,2)-task.rt(trl,1); break;
            end
        end       
    end
    %% response indicator %%
    if ~isempty(selection)         
        if selection == L
            Screen('FillRect',w,white, fracLoc{1});
            DrawFormattedText(w, num2str(certain(t)), valLoc{1}(1), valLoc{1}(2), black);
            task.certain_choice(trl,1) = certain(t);
            
        elseif selection == R %랜덤한 결과값이 나와야한다.   
            Screen('FillRect',w,white, fracLoc{2});
            Screen('FillRect',w,white, fracLoc{3});
            DrawFormattedText(w, num2str(random(1,t)), valLoc{2}(1), valLoc{2}(2), black);                               
            DrawFormattedText(w, num2str(random(2,t)), valLoc{3}(1), valLoc{3}(2), black);
            task.gamble_choice(trl,:) = task.position(trl,:);
        end
    else
        worst_p = [certain(t) random(:,t)']; 
        index = find(worst_p == min(worst_p)); %가장 작은 값 인덱스
        %worst_p(index); %가장 작은 값 
        Screen('FillRect',w,white, fracLoc{index(1)}); %가장 worst 값이 나와야 한다. 
        DrawFormattedText(w, num2str(worst_p(index)), valLoc{index(1)}(1), valLoc{index(1)}(2), black);
    end
    Screen(w,'Flip');%
    while GetSecs - task.onffset(trl,1) < init.iti + init.task_time; end

    %% response result %%
    if ~isempty(selection)         
        if selection == L
            Screen('FillRect',w,white, fracLoc{1});
            DrawFormattedText(w, num2str(certain(t)), valLoc{1}(1), valLoc{1}(2), black);
            task.result(trl,1) = certain(t)
             
        elseif selection == R %랜덤한 결과값이 나와야한다.   
            p = round(rand) + 1  
            Screen('FillRect',w,white, fracLoc{p+1});
            DrawFormattedText(w, num2str(task.position(trl,p)), valLoc{p+1}(1), valLoc{p+1}(2), black);    
            task.result(trl,1) = task.position(trl,p)
        end
        while GetSecs - task.onffset(trl,1) < init.iti + init.task_time + init.present_time ; end
        Screen(w,'Flip');
    end
    
   %% fixtation %% 
    Screen('TextSize', w, init.txtsize1);
    Screen('TextFont', w, 'Malgun Gothic');
    DrawFormattedText(w, '+', 'center', 'center', white)
    while GetSecs - task.onffset(trl,1) < init.iti + init.task_time + init.present_time + init.result_time; end
    Screen('Flip', w);
   %% Ask happyness %%
    DrawFormattedText(w,'How happy are you at this moment?',rect(3)*0.25,rect(4)*0.3, white);
    while GetSecs - task.onffset(trl,1) < init.iti + init.task_time + init.present_time + init.result_time + init.iti; end
    Screen('Flip', w); 

    DrawFormattedText(w,'How happy are you at this moment?',rect(3)*0.25,rect(4)*0.3, white);

    cbar_loc = init.bar_loc(3); percent = 50; ptxt = [num2str(abs(percent)) '%'];
    range_len = 100+abs(init.scale_range(1));
    pstep = round(range_len/(init.bar_length/init.move_step));

    [x_out,y_out] = text_locator(w,ptxt,cbar_loc,init.bar_loc(4),black);
    scale_bar(w,init,init.bar_loc(3),white);
    y_out = y_out - init.bar_height; DrawFormattedText(w,ptxt,x_out,y_out,white);

    while GetSecs - task.onffset(trl,1) < init.ask_prob; end
    Screen(w,'Flip');

     task.rt(trl,4) = GetSecs;
     while GetSecs -  task.rt(trl,4) < init.ask_prob
         [keyisdown,secs,keycode]=KbCheck;
         if keyisdown
             if keycode(keys(1))
                 cbar_loc = cbar_loc-init.move_step;
                 min_loc = init.bar_loc(3) - round(init.bar_length/2);
                 if cbar_loc < min_loc; cbar_loc = min_loc; end

                 percent = percent - pstep;
                 if percent < init.scale_range(1); percent = init.scale_range(1); end
                 ptxt = [num2str(abs(percent)), '%'];
                 [x_out,y_out] = text_locator(w,ptxt,cbar_loc,init.bar_loc(4), black);
                 y_out = y_out - init.bar_height;

                 DrawFormattedText(w,'How happy are you at this moment?',rect(3)*0.25,rect(4)*0.3, white);
                 scale_bar(w,init,cbar_loc,white);
                 DrawFormattedText(w,ptxt,x_out,y_out,white);
                 Screen(w,'Flip'); WaitSecs(0.2);

             elseif keycode(keys(2))
                 cbar_loc = cbar_loc+init.move_step;
                 max_loc = init.bar_loc(3) + round(init.bar_length/2);
                 if cbar_loc > max_loc; cbar_loc = max_loc; end

                 percent = percent + pstep;
                 if percent > 100; percent = 100; end
                 ptxt = [num2str(abs(percent)) '%'];
                 [x_out,y_out] = text_locator(w,ptxt,cbar_loc,init.bar_loc(4),black);
                 y_out = y_out - init.bar_height;

                 DrawFormattedText(w,'How happy are you at this moment?',rect(3)*0.25,rect(4)*0.3,white);
                 scale_bar(w,init,cbar_loc,white);
                 DrawFormattedText(w,ptxt,x_out,y_out,white);
                 Screen(w,'Flip'); WaitSecs(0.2);

             elseif keycode(keys(3))
                 task.rt(trl,5) = GetSecs; task.rt(trl,6) = task.rt(trl,5) - task.rt(trl,4);
                 break;
             end
         end
     end

while GetSecs - task.onffset(trl,1) < init.total_time; end
task.onffset(trl,2) = GetSecs;
Screen(w,'Flip');
end
result_temp = task.result; 
nanidx = find(isnan(result_temp));
result_temp(nanidx) = []

task.score = sum (result_temp(:))
DrawFormattedText(w,['Your total score is ' num2str(task.score)],'center','center',white);
Screen(w,'Flip');
WaitSecs(10);

Screen('CloseAll');
save([data_file_path '\resp_data' num2str(runn) '.mat'],'task','init');

% Wait for a key press 
KbStrokeWait;

% Clear the screen
sca;