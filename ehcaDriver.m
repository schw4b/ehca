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

classdef ehcaDriver
    
    properties (Constant)
        
        VERSION = '0.2'
        
    end
    
    
    properties
        
        nr_trials
        active_segment
        h_fig
              
        segments
        param
        
    end
    
    methods
        
        function obj = ehcaDriver(segments)
            
            obj.active_segment = 1;
            obj.segments = segments;
            obj.nr_trials = length(segments.time);
            
        end
        
        function obj = get_param(obj)
            
            obj = obj.get_head();
            obj = obj.get_eye();
            obj = obj.get_cem();
            
        end
        
        function obj = plot_segment(obj, nr)
            
            color = ehcaPlotProperties();
            
            if isempty(obj.h_fig)
                obj.h_fig = figure('Position', [1 1 300 300]);
            else
                figure(obj.h_fig);
            end
            
            obj.active_segment = nr;            
            plot(obj.segments.time{nr}, obj.segments.eye{nr}, 'k');
            hold on;
            plot(obj.segments.time{nr}, obj.segments.head{nr}, 'k');
            plot(obj.segments.time{nr}, obj.segments.gaze{nr}, 'k--');
            xlim([-0.1 1.1]);
            ylim([-70 70]);
            hold off;
            title(sprintf('%s %d', 'Segment', nr));
            
            % Plot parameters: if there are parameters, we show them
            if ~isempty(obj.param)
                
                hold on;
                % Head
                % Choose data between the onset and offset
                ind = obj.segments.time{nr} >= obj.param.head.on_t(nr) & ...
                    obj.segments.time{nr} <= obj.param.head.off_t(nr);
                plot(obj.segments.time{nr}(ind), obj.segments.head{nr} (ind), ...
                    'color', color.b, 'LineWidth', 2)
                plot(obj.param.head.on_t(nr), ...
                    obj.param.head.on_y(nr), 'color', 'k', 'marker', '+')
                plot(obj.param.head.off_t(nr), ...
                    obj.param.head.off_y(nr), 'color', 'k', 'marker', 'o')
                
                % Eye saccade
                ind = obj.segments.time{nr} >= obj.param.eye.on_t(nr) & ...
                    obj.segments.time{nr} <= obj.param.eye.off_t(nr);
                plot(obj.segments.time{nr}(ind), obj.segments.eye{nr} (ind), ...
                    'color', color.r, 'LineWidth', 2)
                plot(obj.param.eye.on_t(nr), obj.param.eye.on_y(nr), ...
                    'color', 'k', 'marker', '+')
                plot(obj.param.eye.off_t(nr), obj.param.eye.off_y(nr), ...
                    'color', 'k', 'marker', 'o')
                
                % CEM
                ind = obj.segments.time{nr} >= obj.param.cem.on_t(nr) & ...
                    obj.segments.time{nr} <= obj.param.cem.off_t(nr);
                plot(obj.segments.time{nr}(ind), obj.segments.eye{nr} (ind), ...
                    'color', color.g, 'LineWidth', 2)
                plot(obj.param.cem.on_t(nr), obj.param.cem.on_y(nr), ...
                    'color', 'k', 'marker', '+')
                plot(obj.param.cem.off_t(nr), obj.param.cem.off_y(nr), ...
                    'color', 'k', 'marker', 'o')
                hold off;
            end
            
        end
        
        function str = get_nr_trials_str(obj)
            
           str = sprintf('Total: %d', obj.nr_trials);
            
        end
        
        function obj = plot_next(obj)
            
            if obj.active_segment < obj.nr_trials
                obj.plot_segment(obj.active_segment + 1);
                obj.active_segment = obj.active_segment + 1;
            end
            
        end
        
        function obj = plot_back(obj)
            
            if obj.active_segment > 1
                obj.plot_segment(obj.active_segment - 1);
                obj.active_segment = obj.active_segment - 1;
            end
            
        end
        
         function obj = get_head(obj)
            
            for i = 1:obj.nr_trials
                [on_t(i), on_y(i), off_t(i), off_y(i), dur(i), amp(i)] = ...
                    ehcaEmov.get_saccade( ...
                    obj.segments.time{i}, ...
                    obj.segments.head{i}, ...
                    ehcaEmov.HEAD_ONSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.HEAD_OFFSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.MAX_HEAD_DUR * ehcaDemo.SAMPLING);
            end
            
            obj.param.head = struct('on_t',  on_t, 'on_y',  on_y, ...
                'off_t', off_t, 'off_y', off_y, 'dur', dur, 'amp', amp);
            
        end
        
        function obj = get_eye(obj)
            
            for i = 1:obj.nr_trials
                [on_t(i), on_y(i), off_t(i), off_y(i), dur(i), amp(i)] = ...
                    ehcaEmov.get_saccade( ...
                    obj.segments.time{i}, ...
                    obj.segments.eye{i}, ...
                    ehcaEmov.EYE_ONSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.EYE_OFFSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.MAX_EYE_DUR * ehcaDemo.SAMPLING);
            end
            
            obj.param.eye = struct('on_t',  on_t, 'on_y',  on_y, ...
                'off_t', off_t, 'off_y', off_y, 'dur', dur, 'amp', amp);
            
        end
        
        function obj = get_cem(obj)
            
            for i = 1:obj.nr_trials
                [on_t(i), on_y(i), off_t(i), off_y(i), dur(i), amp(i)] = ...
                    ehcaEmov.get_cem( ...
                    obj.segments.time{i}, ...
                    obj.segments.eye{i}, ...
                    ehcaEmov.CEM_ONSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.CEM_OFFSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.MAX_CEM_DUR * ehcaDemo.SAMPLING, ...
                    obj.param.eye.off_t(i), ...
                    ehcaEmov.MAX_CEM_DELAY * ehcaDemo.SAMPLING);
            end
            
            obj.param.cem = struct('on_t',  on_t, 'on_y',  on_y, ...
                'off_t', off_t, 'off_y', off_y, 'dur', dur, 'amp', amp);
        end
        
        function obj = constraints(obj)
            
            % When no head movement, it follows there is no CEM
            % Get trials with no head movement
            ind = find(isnan(obj.head.amp));
            
            % Remove CEM in trials with no head movement
            obj.cem.on_t(ind) = NaN;
            obj.cem.on_y(ind) = NaN;
            obj.cem.off_t(ind) = NaN;
            obj.cem.off_y(ind) = NaN;
            obj.cem.dur(ind) = NaN;
            obj.cem.amp(ind) = NaN;
            
        end
        
        
    end
    
    methods (Static)
        
        function ascii_welcome()
            
            disp( '      _                   Eye-head coordination analyzer' );
            disp(['  ___| |__   ___ __ _     for MATLAB ', ehcaDriver.VERSION] );
            disp( ' / _ \ ''_ \ / __/ _` |' );
            disp( '|  __/ | | | (_| (_|      Copyright (C) 2011, 2012 Simon Schwab' );
            disp( ' \___|_| |_|\___\__,_|    http://sourceforge.net/projects/ehca/' );
            fprintf('\n');
            
        end
        
    end
    
end