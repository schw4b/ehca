% Copyright (C) 2011, 2012  Simon Schwab, schwab@puk.unibe.ch
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>

load reconstruction.mat;

h = figure('Position',[1 1 340 400]);

% % % Original saccade % % %
subplot(2,2,1);
plot(time, saccade_orig, 'k-', 'LineWidth', 2);
vline(0.6);
vline(1);
title('True data')
xlim([0 1.5]);
ylabel('Amplitude (deg)');
[orig.on_t, orig.on_y, orig.off_t, orig.off_y, orig.dur, orig.amp]  = ...
    ehcaEmov.get_saccade(time, saccade_orig, 60/200, 15/200, 0.300*200);
hold on;
plot(orig.on_t, orig.on_y, 'ko');
plot(orig.off_t, orig.off_y, 'ko');
hold off;
set(gca, 'box', 'off') ;

% create an artifact, removing saccadic onset/offset
ind_remove = find(time > 0.6 & time < 1);

saccade_artifact = saccade_orig;
saccade_artifact(ind_remove) = NaN;

subplot(2,3,2);
plot(time, saccade_artifact, 'k-');
title('True data with artifact')
xlim([0 1.5]);
vline(0.6);
vline(1);


subplot(2,3,3);
plot(time, pupil, 'k-');
title('Raw pupil data')
xlim([0 1.5]);

% reconstruction
degree = 2;
x = pupil;
y = saccade_artifact;

% filter NaN because polyfit does not like it.
ind = find(~isnan(y));
x_ = x(ind);
y_ = y(ind);
pol = polyfit(x_, y_, degree);
saccade_rec = x.^2 * pol(1) + x * pol(2) + pol(3);
saccade_rec = ehcaEmov.movavg(3, saccade_rec); % smooth

subplot(2,3,4);
plot(time, saccade_rec, 'k-');

[on_t, on_y, off_t, off_y, dur, amp]  = ...
    ehcaEmov.get_saccade(time, saccade_rec, 60/200, 15/200, 0.300*200);

title('Reconstructed data')
xlim([0 1.5]);

hold on;
plot(on_t, on_y, 'ko');
plot(off_t, off_y, 'ko');

hold off;




