% Parameters for HFA actvation vs. baseline
st.model_lab = 'crRat';
st.trial_cond  = {'all'};
st.evnt_lab = 'MR';
st.stat_lim = 'all';

st.actvwin_len  = .20;
st.actvwin_step = .20;
st.alpha    = 0.05;

%st.n_boots  = 1000;
st.corrwin_len  = 15.0;
st.corrwin_step = 1.0;
st.alpha    = 0.05;

% st.xcorr_method = 'max';
% st.xcorr_method = 'min';
 st.xcorr_method = 'max';

st.win_lag = 5.0;