% Parameters for HFA actvation vs. baseline
st.model_lab = 'crIBI';
st.trial_cond  = {'all'};
st.evnt_lab = 'MR';
st.stat_lim = 'all';

%st.n_boots  = 1000;
st.win_len  = 15.0;
st.win_step = 1.0;
st.alpha    = 0.05;

% st.xcorr_method = 'max';
% st.xcorr_method = 'min';
 st.xcorr_method = 'abs';

st.win_lag = 5.0;