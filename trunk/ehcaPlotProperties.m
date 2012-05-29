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

classdef ehcaPlotProperties

    properties

        r % red
        g % green
        b % blue
        k % black
        v % violet
        y % yellow
        e % grey
        
        lr % light red
        lg % light green
        lb % light blue
        
        colormaps

    end

    methods

        function obj = ehcaPlotProperties()

            obj.r = [.8 .3 .3];
            obj.g = [.2 .6 .2];
            obj.b = [.2 .2 .8];
            obj.k = [.1 .1 .1];
            obj.v = [.8 .3 .8];
            obj.y = [.8 .8 .3];
            obj.e = [.6 .6 .6];
            
            % light colors
            obj.lr = [.9 .7 .7];
            obj.lg = [.7 .9 .7];
            obj.lb = [.7 .7 .9];
            
            obj.colormaps.red = [obj.r; [1 1 1]];           
            
        end
        
        function obj = test_colors(obj)
            
            figure;
            plot(rand(1,10), 'color', obj.r, 'marker', 'o');
            hold on;
            plot(rand(1,10), 'color', obj.g, 'marker', '+');
            plot(rand(1,10), 'color', obj.b, 'marker', 'x');
            plot(rand(1,10), 'color', obj.k, 'marker', 'o');
            plot(rand(1,10), 'color', obj.v, 'marker', '+');
            plot(rand(1,10), 'color', obj.y, 'marker', 'x');
            plot(rand(1,10), 'color', obj.e, 'marker', 'x');
            
        end
        
        function obj = test_light_colors(obj)
            
            figure;
            x = rand(1,10);
            y = rand(1,10);
            z = rand(1,10);
            
            hold on;
            plot(x, 'color', obj.lr, 'LineWidth', 6);
            plot(x, 'k', 'LineWidth', 2);
            
            plot(y, 'color', obj.lg, 'LineWidth', 6);
            plot(y, 'k', 'LineWidth', 2);
            
            plot(z, 'color', obj.lb, 'LineWidth', 6);  
            plot(z, 'k', 'LineWidth', 2);
        end

    end

    methods(Static)

        function set(ylimit)

            xlim([0 2]);
            ylim([-ylimit ylimit]);
            xlabel('Time (s)');
            ylabel('Amplitude (deg)');
            %set(gca,'YGrid','on');
            set(gca,'YTick',-50:20:50);
            set(gca,'XTick',0:0.5:2);
            grid off;

        end

    end

end