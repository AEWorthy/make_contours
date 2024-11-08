# make_contours
make_contours: Alvarez 2023 Version.

This is a contour-making MATLAB script originally made by Tim Machado, Jessell Lab, Columbia University (C) 2015: see license.txt for details. 

Small edits were made to the original version by members of the Alvarez Lab (Ryan Wood and Andrew Worthy) to make contour images for Worthy et al. 2024, eLife (https://doi.org/10.7554/eLife.95172.2). Contact Andrew Worthy (aeworth@emory.edu) for any questions about this version.

----------------------------------------------------------------

# ORIGINAL README:

Change your working directory to the extracted zip file, you can
just type "make_contours," at the MATLAB command line and it will make
plots for all of the data files present in the ../make_contours/text/
folder.

The plots will be saved in the ../make_contours/plots/ folder as pdf
files that you can modify in Illustrator.

There are two example .csv files for you to look at so you can format
your data appropriately. Each row contains the x,y coordinate for a
neuron, except for the last four rows, which contain "registration
points" that are ignored and not plotted. All text files must be registered
to a common coordinate system before running this script.

You should ensure that your data are properly scaled to fit within the
default grid size, or specify different grid dimensions that are
appropriate for your data.

Detailed documentation is below.

Tim Machado, Jessell Lab, Columbia University

----------------------------------------------------------------

  make_contours(xGrid,yGrid,xLims,yLims)

  make contours around the kernel density estimated from a
  list of 2d coordinates and save out the resulting plots

 REQUIRED ARGUMENTS:

  files containing coordinates of neurons must be present in
  ../make_contours/text/ they must be in in .csv format with the last N_LANDMARK
 rows containing registration points that will not be plotted.

  OPTIONAL ARGUMENTS:

  xGrid
  yGrid - limits for grid used for kernel density estimate (microns)
          defaults: xGrid = [0 1000], yGrid = [-400 600];
  xLims
  yLims - limits for plotting hemicord cartoon (microns)
          defaults: xLims = [0 650],  yLims = [-400 500];

  parameters for kernel density estimation are hardcoded as constants
  at the beginning of this text file

  N_BINS = 256, how big is the N_BINS x N_BINS kernel density map
  N_LEVELS = 9, number of contour levels to plot on kernel density estimate
  N_LANDMARKS = 4, number of registration coordinates present
                   at the end of each data file

  RETURN VALUES:

  saves scatter and kernel density plots to ../make_contours/plots/
  allData - cell array with the coordinates of each neuron in each dataset
  names -  filename of each text files read in