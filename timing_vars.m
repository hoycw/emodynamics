
%% Times of trial elements (in sec)

% Movie names
times.movie_names = {...
    ['Disgust_Roaches'],...
    ['Happy_Modern Times'],...
    ['Fear_Witness'],...
    ['Neutral_Sticks'],...    
    ['Fear_Cujo'],...
    ['Disgust_Poop Lady'],...    
    ['Neutral_ColorBars'],...
    ['Happy_Lucy']};

% Time for baseline fixation
times.bsln_len = 32;
% Time for movies in sec (Lucy is +5s)
times.movie_len = [90.133 90.067 90.133 90.067 90.133 90.033 90.133 94.7];
% Time for recovery (neutral) movie
times.recov_len = 32.033;

% 30 frames per second (from #0 to #29)
% format: MM:SS:frame number
% MM = 00-59
% SS = 00-59
% frame number = 00-29


% 1. Disgust: Roaches (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:03
%       Recovery:   2:02:04 - 2:34:04
%       Event:      0:47:08
%       Event:      1:12:07
%       Event:      1:33:11

% 2. Happy: Modern Times (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:01
%       Recovery:   2:02:02 - 2:34:02

% 3. Fear: Witness (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:03
%       Recovery:   2:02:04 - 2:34:04
%       Event:      1:18:07 (not clear)

% 4. Neutral: Sticks (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:01
%       Recovery:   2:02:02 - 2:34:02
%       Event:      0:38:22
%       Event:      0:45:27
%       Event:      0:53:03
%       Event:      1:00:07
%       Event:      1:06:27
%       Event:      1:14:01
%       Event:      1:21:20
%       Event:      1:29:02
%       Event:      1:36:22
%       Event:      1:43:22
%       Event:      1:50:18
%       Event:      1:57:10

% 5. Fear: Cujo (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:03
%       Recovery:   2:02:04 - 2:34:04
%       Event:      1:22:07

% 6. Disgust: Poop Lady (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:00
%       Recovery:   2:02:01 - 2:34:01
%       Event:      --

% 7. Neutral: ColorBars (154000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:02:03
%       Recovery:   2:02:04 - 2:34:04
%       Event:      0:42:00
%       Event:      0:52:00
%       Event:      1:02:02
%       Event:      1:12:02
%       Event:      1:22:02
%       Event:      1:32:02
%       Event:      1:42:02
%       Event:      1:52:02

% 8. Happy: Lucy (159000 ms)
%       Baseline:   0:00:00 - 0:31:29
%       Film:       0:32:00 - 2:06:20
%       Recovery:   2:06:21 - 2:38:21
%       Event:      1:59:04



%%
% format: MM:SS:Millisecond
% MM = 00-59
% SS = 00-59
% Millisecond = 000-999


% 1. Disgust: Roaches (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:133
%       Recovery:   2:02:134 - 2:34:167
%       Event:      0:47:268
%       Event:      1:12:234
%       Event:      1:33:368

% 2. Happy: Modern Times (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:067
%       Recovery:   2:02:068 - 2:34:100

% 3. Fear: Witness (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:133
%       Recovery:   2:02:134 - 2:34:167
%       Event:      1:18:234 (not clear)

% 4. Neutral: Sticks (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:067
%       Recovery:   2:02:068 - 2:34:100
%       Event:      0:38:734
%       Event:      0:45:901
%       Event:      0:53:101
%       Event:      1:00:234
%       Event:      1:06:901
%       Event:      1:14:034
%       Event:      1:21:668
%       Event:      1:29:068
%       Event:      1:36:734
%       Event:      1:43:734
%       Event:      1:50:601
%       Event:      1:57:334

% 5. Fear: Cujo (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:133
%       Recovery:   2:02:134 - 2:34:167
%       Event:      1:22:234

% 6. Disgust: Poop Lady (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:033
%       Recovery:   2:02:034 - 2:34:067
%       Event:      --

% 7. Neutral: ColorBars (154000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:02:133
%       Recovery:   2:02:134 - 2:34:167
%       Event:      0:42:001
%       Event:      0:52:001
%       Event:      1:02:068
%       Event:      1:12:068
%       Event:      1:22:068
%       Event:      1:32:068
%       Event:      1:42:068
%       Event:      1:52:068

% 8. Happy: Lucy (159000 ms)
%       Baseline:   0:00:001 - 0:32:000
%       Film:       0:32:001 - 2:06:700
%       Recovery:   2:06:701 - 2:38:733
%       Event:      1:59:134


%%
% format: SS.milliseconds

% times.event= {...
%     [47.268,72.234,93.368],...
%     [],...
%     [78.234],...
%     [38.734, 45.901, 53.101, 60.234, 66.901, 74.034, 81.668, 89.068, 96.734, 103.734, 110.601, 117.334],...
%     [82.234],...
%     [],...
%     [42.001, 52.001, 62.068, 72.068, 82.068, 92.068, 102.068, 112.068],...    
%     [119.134]}

times.event= {...
    [47.268,72.234,93.368],...
    [],...
    [78.234],...
    [],...
    [82.234],...
    [],...
    [],...    
    [119.134]}


% 1. Disgust: Roaches (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.133
%       Recovery:   122.134 - 154.167
%       Event:      47.268
%       Event:      72.234
%       Event:      93.368


% 2. Happy: Modern Times (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.067
%       Recovery:   122.068 - 154.100

% 3. Fear: Witness (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.133
%       Recovery:   122.134 - 154.167
%       Event:      78.234 (not clear)

% 4. Neutral: Sticks (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.067
%       Recovery:   122.068 - 154.100
%       Event:      38.734
%       Event:      45.901
%       Event:      53.101
%       Event:      60.234
%       Event:      66.901
%       Event:      74.034
%       Event:      81.668
%       Event:      89.068
%       Event:      96.734
%       Event:      103.734
%       Event:      110.601
%       Event:      117.334

% 5. Fear: Cujo (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.133
%       Recovery:   122.134 - 154.167
%       Event:      82.234

% 6. Disgust: Poop Lady (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.033
%       Recovery:   122.034 - 154.067
%       Event:      --

% 7. Neutral: ColorBars (154000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 122.133
%       Recovery:   122.134 - 154.167
%       Event:      42.001
%       Event:      52.001
%       Event:      62.068
%       Event:      72.068
%       Event:      82.068
%       Event:      92.068
%       Event:      102.068
%       Event:      112.068

% 8. Happy: Lucy (159000 ms)
%       Baseline:   0.001 - 32.000
%       Film:       32.001 - 126.700
%       Recovery:   126.701 - 158.733
%       Event:      119.134

%% Frame to time convert

% Frame - Frame start time -- Frame end time 

% 00	001	033
% 01	034	067
% 02	068	100
% 03	101	133
% 04	134	167
% 05	168	200
% 06	201	233
% 07	234	267
% 08	268	300
% 09	301	333
% 10	334	367
% 11	368	400
% 12	401	433
% 13	434	467
% 14	468	500
% 15	501	533
% 16	534	567
% 17	568	600
% 18	601	633
% 19	634	667
% 20	668	700
% 21	701	733
% 22	734	767
% 23	768	800
% 24	801	833
% 25	834	867
% 26	868	900
% 27	901	933
% 28	934	967
% 29	968	1000

