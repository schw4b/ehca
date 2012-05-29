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

classdef ehcaEmov

    properties (Constant)

        MAX_SACCADE_VELOCITY = 3.75; % default 3.75 (750 deg/sec at 200 Hz)

        HEAD_ONSET_VELOCITY = 20; % deg/sec  default 20
        HEAD_OFFSET_VELOCITY = 15;  % default 15

        EYE_ONSET_VELOCITY = 60;  % default 60
        EYE_OFFSET_VELOCITY = 15;  % default 15

        CEM_ONSET_VELOCITY = 15; % default 15
        CEM_OFFSET_VELOCITY = 5; % default  5

        MAX_HEAD_DUR = 0.600; % default 0.600 ms
        MAX_EYE_DUR = 0.300;  % default 0.300 ms
        MAX_CEM_DUR = 0.360;  % default 0.360 ms
        MAX_CEM_DELAY = 0.050;% default 0.050 ms

    end

    methods (Static)

        % I-DT Algorithm for fixation detection.
        % Salvucci, D. D., & Goldberg, J. H. (2000). Identifying fixations
        % and saccades in eye-tracking protocols. In Proceedings of the
        % Eye Tracking Research and Applications Symposium (pp. 71-78).
        % New York: ACM Press.
        function fixations = get_fixations(azimuth, elevation, ...
                dispersion, duration)

            assert (length(azimuth) == length(elevation));
            assert (length(azimuth) > duration);

            % create moving window
            start = 1; % window start position
            k = 1; % fixation counter
            while start <= length(azimuth) - duration

                ending = start + duration - 1; % window end position
                x = azimuth(start:ending);
                y = elevation(start:ending);
                D = (max(x) - min(x)) + (max(y) - min(y));

                j = 1; % window expander
                while D <= dispersion && ...
                        ending + j <= length(azimuth)
                    % expand window by 1 using j
                    x = azimuth(start:ending + j);
                    y = elevation(start:ending + j);
                    D = (max(x) - min(x)) + (max(y) - min(y));

                    if D > dispersion
                        fixations{1}(k) = start; % Start
                        fixations{2}(k) = ending + j - 1; % End
                        fixations{3}(k) = nanmean(x);
                        fixations{4}(k) = nanmean(y);
                        k = k + 1;
                        start = ending + j - 1; % Skip window points
                        break;

                        % handle last window
                    elseif ending + j == length(azimuth)
                        fixations{1}(k) = start; % Start
                        fixatiosn{2}(k) = ending + j; % End
                        fixations{3}(k) = nanmean(x);
                        fixations{4}(k) = nanmean(y);
                        start = ending + j; % Skip window points
                        break;

                    end

                    j = j + 1;

                end

                start = start + 1;

            end

        end

        % movavg: Moving average.
        function y = movavg(windowSize, x)

            assert(rem(windowSize, 2) == 1, ...
                'Filter length must be an odd number!');

            is_horz = 1;
            s = size(x);
            if s(1) > s(2)
                is_horz = 0;
            end


            a = 1;
            b = ones(1, windowSize)/windowSize;
            y = filter(b, a, x);
            delay = (length(b) - 1)/2;

            % remove guessed values by the filter function
            y = y(length(b):end);

            % add delay as NaN values

            if is_horz
                missing = nan(1, delay);
                y = horzcat(missing, y, missing);
            else
                missing = nan(delay, 1);
                y = vertcat(missing, y, missing);
            end

        end

        function x = filter_saccades(x)

            % filter eye saccades above 750 deg/sec.
            ind = find(abs(diff(x)) > ...
                ehcaEmov.MAX_SACCADE_VELOCITY);

            x(ind) = NaN;
            x(ind + 1) = NaN;

        end

        % Gets first saccades of eye or head movement. Returns
        % onset/offset and amplitude.
        % on_vel: onset velocity
        % off_vel: offset velocity
        function [on_t, on_y, off_t, off_y, dur, amp] ...
                = get_saccade(t, y, on_vel, off_vel, max_dur)

            win = 15; % window size to detect onsets
            consecutives = 5; % nr of consecutives velocities

            % get onset
            v = abs(diff(y));
            ind = find(v >= on_vel, win);

            on = NaN;
            on_t = NaN;
            on_y = NaN;
            off_t = NaN;
            off_y = NaN;

            % find first index i with has consecutives
            for i = 1:(length(ind) - consecutives + 1)

                if ...
                        (...
                        (ind(i) == 1 || ~isnan(v(ind(i)- 1))) && ...
                        ind(i)    == ind(i+1) - 1 && ...
                        ind(i+1)  == ind(i+2) - 1 && ...
                        ind(i+2)  == ind(i+3) - 1 && ...
                        ind(i+3)  == ind(i+4) - 1)

                    on = ind(i);
                    on_t = t(ind(i));
                    on_y = y(ind(i));
                    break;

                end

            end

            % get offset (only if an onset was found)
            if ~isnan(on)
                if (on + 1 + max_dur) > length(v) % max_dur may exceed v
                    v = v(on + 1:end);
                else
                    v = v(on + 1:on + 1 + max_dur);
                end
            end

            % i + 1 element is taken for symmetry
            off = find(v <= off_vel, 1) + on + 1;

            if ~isnan(off)
                off_t = t(off);
                off_y = y(off);
            end

            amp = abs(off_y - on_y); % Amplitude
            dur = off_t - on_t; % Duration from onset to offset

        end

        % Gets CEM. Returns onset/offset and amplitude.
        % on_vel: onset velocity
        % off_vel: offset velocity
        % max_dur: maximum duration allowed for CEM, e.g. 220 ms
        % max_delay: delay allowed after eye offset, e.g. 10 samples
        function [on_t, on_y, off_t, off_y, dur, amp] ...
                = get_cem(t, y, on_vel, off_vel, max_dur, eye_off, max_delay)

            on = NaN;
            on_t = NaN;
            on_y = NaN;
            off_t = NaN;
            off_y = NaN;

            % Get onset
            v = abs(diff(y));

            % cem only detected if there is an eye offset
            % look after eye offset
            if ~isnan(eye_off)
                start = find(t >= eye_off, 1);

                % start must not be at the very end of the serach window
                if (start < length(t) - max_dur - max_delay)
                    v = v(start:start + max_delay - 1);
                    on = find(v >= on_vel, 1) + start - 1;
                end

                if isempty(on) || isnan(on)
                    on = NaN;
                else
                    on_t = t(on);
                    on_y = y(on);
                end

            end

            v = abs(diff(y));
            % get offset (only if an onset was found)
            % look after CEM onset
            if ~isnan(on)
                v = v(on + 1:on + 1 + max_dur);
            end

            % i + 1 element is taken for symmetry
            off = find(v <= off_vel, 1) + on + 1;

            if ~isnan(off)
                off_t = t(off);
                off_y = y(off);
            end

            amp = abs(off_y - on_y); % Amplitude
            dur = off_t - on_t; % Duration from onset to offset

        end

        % trial: trial number to test the algorithm upon
        % subject: ehcaSubject data set
        function test_get_saccede(subject, trial)

            t = subject.segments.time{trial};
            y = subject.segments.pupil_azimuth{trial};

            figure;
            plot(t, y, 'r');
            hold on;

            % eye
            [on_t, on_y, off_t, off_y, dur, amp] = ...
                ehcaEmov.get_saccade(t, y, ...
                ehcaEmov.EYE_ONSET_VELOCITY/ehcaIview.SAMPLING,...
                ehcaEmov.EYE_OFFSET_VELOCITY/ehcaIview.SAMPLING, ...
                ehcaEmov.MAX_EYE_DUR * ehcaIview.SAMPLING);


            plot(on_t, on_y, 'r+');
            plot(off_t, off_y, 'ro');

            % cem
            [on_t, on_y, off_t, off_y, dur, amp] = ...
                ehcaEmov.get_cem(t, y, ...
                ehcaEmov.CEM_ONSET_VELOCITY/ehcaIview.SAMPLING, ...
                ehcaEmov.CEM_OFFSET_VELOCITY/ehcaIview.SAMPLING, ...
                ehcaEmov.MAX_CEM_DUR * ehcaIview.SAMPLING, ...
                off_t, ...
                ehcaEmov.MAX_CEM_DELAY * ehcaIview.SAMPLING);
            plot(on_t, on_y, '+g');
            plot(off_t, off_y, 'og');

        end

    end

end