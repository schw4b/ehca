% Copyright (C) 2011  Simon Schwab, schwab@puk.unibe.ch
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

classdef ehcaDemo
    
    properties (Constant)
        
        SAMPLING = 200; % 200Hz
        NR_OF_SEGMENTS = 11;
        
    end
    
    properties
        
        head
        eye
        cem % compensatory eye movement
        segments
        
    end
    
    methods
        
        function obj = ehcaDemo(segments)
            
            obj.segments = segments;
            obj = obj.get_head();
            obj = obj.get_eye();
            obj = obj.get_cem();
            obj = obj.constraints();
            
        end
        
        function obj = get_head(obj)
            
            for i = 1:ehcaDemo.NR_OF_SEGMENTS
                [on_t(i), on_y(i), off_t(i), off_y(i), dur(i), amp(i)] = ...
                    ehcaEmov.get_saccade( ...
                    obj.segments.time{i}, ...
                    obj.segments.head{i}, ...
                    ehcaEmov.HEAD_ONSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.HEAD_OFFSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.MAX_HEAD_DUR * ehcaDemo.SAMPLING);
            end
            
            obj.head = struct('on_t',  on_t, 'on_y',  on_y, ...
                'off_t', off_t, 'off_y', off_y, 'dur', dur, 'amp', amp);
            
        end
        
        function obj = get_eye(obj)
            
            for i = 1:ehcaDemo.NR_OF_SEGMENTS
                [on_t(i), on_y(i), off_t(i), off_y(i), dur(i), amp(i)] = ...
                    ehcaEmov.get_saccade( ...
                    obj.segments.time{i}, ...
                    obj.segments.eye{i}, ...
                    ehcaEmov.EYE_ONSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.EYE_OFFSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.MAX_EYE_DUR * ehcaDemo.SAMPLING);
            end
            
            obj.eye = struct('on_t',  on_t, 'on_y',  on_y, ...
                'off_t', off_t, 'off_y', off_y, 'dur', dur, 'amp', amp);
            
        end
        
        function obj = get_cem(obj)
            
            for i = 1:ehcaDemo.NR_OF_SEGMENTS
                [on_t(i), on_y(i), off_t(i), off_y(i), dur(i), amp(i)] = ...
                    ehcaEmov.get_cem( ...
                    obj.segments.time{i}, ...
                    obj.segments.eye{i}, ...
                    ehcaEmov.CEM_ONSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.CEM_OFFSET_VELOCITY/ehcaDemo.SAMPLING, ...
                    ehcaEmov.MAX_CEM_DUR * ehcaDemo.SAMPLING, ...
                    obj.eye.off_t(i), ...
                    ehcaEmov.MAX_CEM_DELAY * ehcaDemo.SAMPLING);
            end
            
            obj.cem = struct('on_t',  on_t, 'on_y',  on_y, ...
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
        
        % sss %
        function obj = plot_segments(obj)
            
            h = figure('Position',[1 1 500 450]);
            
            p = ehcaPlotProperties(); % we have our own colors
            
            for i = 1:ehcaDemo.NR_OF_SEGMENTS
                
                subplot(3, 4, i);      
                
                hold on;
                
                % Plot parameters
                
                % Head
                % Choose data between the onset and offset
                ind = obj.segments.time{i} >= obj.head.on_t(i) & ...
                    obj.segments.time{i} <= obj.head.off_t(i);
                plot(obj.segments.time{i}(ind), obj.segments.head{i} (ind), ...
                    'color', p.lb, 'LineWidth', 4)
                %plot(obj.head.on_t(i), obj.head.on_y(i), 'color', 'k', 'marker', '+')
                %plot(obj.head.off_t(i), obj.head.off_y(i), 'color', 'k', 'marker', 'o')
                
                % Eye saccade
                % Choose data between the onset and offset
                ind = obj.segments.time{i} >= obj.eye.on_t(i) & ...
                    obj.segments.time{i} <= obj.eye.off_t(i);
                plot(obj.segments.time{i}(ind), obj.segments.eye{i} (ind), ...
                    'color', p.lr, 'LineWidth', 4)
                %plot(obj.eye.on_t(i), obj.eye.on_y(i), 'color', 'k', 'marker', '+')
                %plot(obj.eye.off_t(i), obj.eye.off_y(i), 'color', 'k', 'marker', 'o')
                
                % CEM
                % Choose data between the onset and offset
                ind = obj.segments.time{i} >= obj.cem.on_t(i) & ...
                    obj.segments.time{i} <= obj.cem.off_t(i);
                plot(obj.segments.time{i}(ind), obj.segments.eye{i} (ind), ...
                    'color', p.lg, 'LineWidth', 4)
                %plot(obj.cem.on_t(i), obj.cem.on_y(i), 'color', 'k', 'marker', '+')
                %plot(obj.cem.off_t(i), obj.cem.off_y(i), 'color', 'k', 'marker', 'o')
                
                ylim([-10 65]);
                xlim([0 1]);
                %title(sprintf('%s %d, %s %d', 'Sub', i, 'Tr',  ...
                %    obj.segments.nr(i)));
                title(sprintf('%s %d', 'Subject', i));
                
                % Plot signals
                plot(obj.segments.time{i}, obj.segments.head{i}, 'k');
                plot(obj.segments.time{i}, obj.segments.eye{i}, 'k');
                plot(obj.segments.time{i}, obj.segments.gaze{i}, 'k--');
                
                if i == 1
                    set(gca, 'box', 'off');
                else
                    axis off;
                end
                
            end
            
        end
        
        function obj = plot_segment(obj, nr)
            
            h = figure;
            plot(obj.segments.time{nr}, obj.segments.eye{nr}, 'k');
            hold on;
            plot(obj.segments.time{nr}, obj.segments.head{nr}, 'k');
            plot(obj.segments.time{nr}, obj.segments.gaze{nr}, 'k--');
            xlim([0 1]);
            hold off;            
            title(sprintf('%s %d, %s %d', 'Subject', nr, 'Trial',  ...
                    obj.segments.nr(nr)));
                
        end
        
    end
    
end