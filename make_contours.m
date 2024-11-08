%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_contours(xGrid,yGrid,xLims,yLims)
%
%
% make contours around the kernel density estimated from a
% list of 2d coordinates and save out the resulting plots
%  
% REQUIRED ARGUMENTS:
% 
% files containing coordinates of neurons must be present in 
% ../make_contours/text/ they must be in csv format.
% 
% OPTIONAL ARGUMENTS:
%
% xGrid
% yGrid - limits for grid used for kernel density estimate (microns)
%         defaults: xGrid = [0 710], yGrid = [-400 500];
% xLims
% yLims - limits for plotting hemicord cartoon (microns)
%         defaults: xLims = [0 710],  yLims = [-400 500];
% 
% parameters for kernel density estimation are hardcoded as constants
% at the beginning of this text file
%
% N_BINS = 256, how big is the N_BINS x N_BINS kernel density map
% N_LEVELS = 9, number of contour levels to plot on kernel density estimate
%
% RETURN VALUES:
%
% saves scatter and kernel density plots to ../make_contours/plots/
% allData - cell array with the coordinates of each neuron in each dataset
% names -  filename of each text files read in
%
% rwood, updated 2/2021
% orginator: Tim Machado, tam2138@columbia.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [allData, names] = make_contours(xGrid,yGrid,xLims,yLims)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define constants and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constants
CORD_COLOR = [.96 .96 .96]; % color for spinal cord outline (.96 = 245/255)
N_LEVELS = 9;               % how many contour levels should we draw?
N_BINS = 256;               % how big of an NxN matrix to use for kde?
xALL = [0 700]; %for easy changing xGrid and xLims
yALL = [-500 450]; %for easy changing yGrid and yLims

% define limits for plotting stuff (in microns)
if nargin < 4
    if ~exist('xGrid','var') || ~exist('yGrid','var')
       xGrid = xALL; yGrid = yALL; % limits for kde grid
    end
    if ~exist('xLims','var') || ~exist('yLims','var')  
       xLims = xALL;  yLims = yALL; % limits for plotting cords
    end
end

% add export_fig to the path for saving pretty pdfs if necessary
if isempty(which('export_fig'))
    path = which('make_contours');
    ind = strfind(path,'make_contours.m');
    addpath([path(1:ind-1) 'export_fig']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare stuff for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close all open figures
close all;

% get dataset names
[names, paths] = get_dataset_names;
nDatasets = length(paths);

% accumulate all points as we load datasets; return this value
allData = cell(nDatasets,1);

% scale cord and translate cord outline
load('cord');  
cord.x = cord.x * diff(xLims);
cord.y = cord.y * diff(yLims);
cord.x = cord.x - min(cord.x) + xLims(1); 
cord.y = cord.y - min(cord.y) + yLims(1);

% generate three ticks for each axis
xticks = [xLims(1) 0 xLims(2)];
yticks = [yLims(1) 0 yLims(2)];
if min(xLims) >= 0, xticks = [xLims(1) round(mean(xLims)) xLims(2)]; end
if min(xLims) >= 0, yticks = [yLims(1) round(mean(yLims)) yLims(2)]; end

% get bounds for plotting contours
xBounds = linspace(xGrid(1),xGrid(2),N_BINS);
yBounds = linspace(yGrid(1),yGrid(2),N_BINS);

% set up figures for plotting
contourOverlay = figure; set(gcf,'Color','w');
contourMatrix = figure; set(gcf,'Color','w');
contourData = figure; set(gcf,'Color','w');

% colors to use for big matrix of all contours
cols = jet(nDatasets);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make all plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:nDatasets
    % load in data from file and flip over x axis
    data = importdata(paths{ii});
    data = data.data;
    data(:,1) = -(data(:,1));
    
    % save data
    allData{ii} = data;
    
    % plot data points
    figure(contourData);
    cax = subplot(1,2,1);
    make_spinal_cord(cax);
    title(names(ii,:));
    plot(data(1:end,1),data(1:end,2),'k.');
    fix_axes(cax)
    
    % plot individual contours based on kernel density
    cax = subplot(1,2,2);
    make_spinal_cord(cax);
    
    % get kernel density function
    [~, density] = kde2d(data(1:end,:),N_BINS,...
        [xGrid(1) yGrid(1)],[xGrid(2) yGrid(2)]);
    
    % make and contours around kernel density function
    plot_contours(cax,density,xBounds,yBounds);
    fix_axes(cax);
    
    % print current image
    fname = ['plots\' names{ii} '.pdf'];
    export_fig(contourData, 'pdf', fname);
    
    % show each contour in its own subplot
    if nDatasets > 1
        figure(contourMatrix);
        % (Andrew) plots figures side-by-side in a variable length page
        cax = subplot((nDatasets/2),2,ii);
        make_spinal_cord(cax);
        plot_contours(cax,density,xBounds,yBounds,cols(ii,:));
        axis image;
        title(names(ii,:));

        % print all contours
        if ii == nDatasets
            set(gcf, 'Position', get(0,'Screensize'));
            export_fig(contourMatrix,'pdf','plots\all-contours.pdf');
        end
    else
        close(contourMatrix)
    end
    
    % plot all data points on one plot
    figure(contourOverlay); 
    cax = subplot(3,2,1);
    if ii == 1, make_spinal_cord(cax); end
    title('all lumbar sections');
    plot(data(1:end,1),data(1:end,2),...
        '.','Color',cols(ii,:),'MarkerSize',4);
    fix_axes(cax)
    
    % plot all contours on one plot
    cax = subplot(1,2,2);
    if ii == 1, make_spinal_cord(cax); end
    plot_contours(cax,density,xBounds,yBounds,cols(ii,:));
    fix_axes(cax)
end

% save out summary plot
export_fig(contourOverlay,'pdf','plots\summary.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper functions used during plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot contours on kernel density
function plot_contours(cax,density,xBounds,yBounds,color)
    
    % setup the axes
    if nargin < 5, color = 'k'; end
    axes(cax);
    
    % use contourf instead of contour because contourf draws smoother lines
    % (Andrew) changed contourf to contour to prevent filling.
    [~,h] = contour(xBounds,yBounds,density,N_LEVELS,'Color',color);
    
    % get rid of any colors on contour shapes
    allH = allchild(h);
    if ~isempty(allH)
        set(allH,'FaceColor','none'); 
        % hide box around contours
        set(allH(end),'EdgeColor','none');
    end
end

% print spinal cord outline
function make_spinal_cord(cax)
    
    % setup the axes
    axes(cax);
    hold on;
    set(cax,'TickDir','out','Layer','top');
    
    % draw the spinal cord outline
    patch(cord.x,cord.y,CORD_COLOR,'EdgeColor','k');
end

% standardize the axes we're using once we've plotted everything in them
function fix_axes(cax)
    axes(cax);
    axis image; xlabel('\mum'); ylabel('\mum');
    ylim(yLims); xlim(xLims);
    set(gca,'XTick',xticks,'YTick',yticks);
end
end