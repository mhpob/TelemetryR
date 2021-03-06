% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trans_loss.R
\name{trans_loss}
\alias{trans_loss}
\title{Calculate number of transmitters remaining over time}
\usage{
trans_loss(data, dates, group, stdate = NULL, enddate = NULL)
}
\arguments{
\item{data}{Data frame. Detection data including date and time of detection,
as well as a group identifier.}

\item{dates}{Date- or POSIX-class. Date and time of detections.}

\item{group}{Character. Group identifier (transmitter, fish ID, etc.).}

\item{stdate}{Date- or POSIX-class. Which day you want the time series to start?
Defaults to day of earliest detection in the data set. Must be the same
class as \code{enddate}}

\item{enddate}{Date- or POSIX-class.}
}
\value{
Output is a data frame containing the number of each group remaining
   at each date.
}
\description{
\code{trans_loss} returns the number of transmitters (or other group) remaining
each day of a given time period
}
\details{
This function finds the most-recent date of detection for each group (i.e.,
transmitter/fish). For each date in a given range, it then counts the number
of fish that have a more-recent final detection date.
}
