basic_circle <-  circleGrob(name = "basic_circle", 
                            x = 0.5, y = 0.5, r = 0.5, 
                            gp = gpar(col =  "darkred", lty = 3))

grid.draw(basic_circle)


# circle_square
my_circle <- circleGrob(name = "my_circle",
                        x = 0.5, y = 0.5, r = 0.5,
                        gp = gpar(col = "gray", lty = 3))
grid.draw(my_circle)

my_rect <- rectGrob(x = 0.5, y = 0.5, width = 0.8, height = 0.3)
grid.draw(my_rect)
# red_circle
grid.edit("my_circle", gp = gpar(col = "red", lty = 1))


# scatter_circle
wrldcp_scatter <- ggplot(worldcup, aes(Time, Passes)) +
  geom_point()

grid.draw(wrldcp_scatter)
grid.draw(my_circle)

# scatter
wrldcp_scatter
grid.force()
grid.ls()
# red_scatter
grid.edit("geom_point.points.52", gp = gpar(col = "darkred"))

# boxplot
box <- rectGrob(x = 0.5, y = 0.5, width = 0.25, height = 0.25)
iqr1 <- segmentsGrob(x0 = 0.5, x1 = 0.5, y0 = 0.625, y1 = 0.75)
iqr1_line <- segmentsGrob(x0 = 0.4, x1 = 0.6, y0 = 0.75, y1 = 0.75)
median_line<- segmentsGrob(x0 = 0.375, x1 = 0.625, y0 = 0.5, y1 = 0.5)
iqr3 <- segmentsGrob(x0 = 0.5, x1 = 0.5, y0 = 0.25, y1 = 0.375)
iqr3_line <- segmentsGrob(x0 = 0.4, x1 = 0.6, y0 = 0.25, y1 = 0.25)
boxplot <- gTree(children = gList(box, median_line, iqr1, iqr1_line, iqr3, iqr3_line))

grid.draw(boxplot)

# viewport_box
grid.draw(rectGrob())
sample_vp <- viewport(x = 0.5, y = 0.5, 
                      width = 0.5, height = 0.5,
                      just = c("left", "bottom"))
pushViewport(sample_vp)
grid.draw(roundrectGrob())
grid.draw(boxplot)
popViewport()

# vp_box_center
grid.draw(rectGrob())
sample_vp <- viewport(x = 0.5, y = 0.5, 
                      width = 0.5, height = 0.5,
                      just = c("center", "center"))
pushViewport(sample_vp)
grid.draw(roundrectGrob())
grid.draw(boxplot)
popViewport()

# vp_box_double
grid.draw(rectGrob())
sample_vp <- viewport(x = 0.75, y = 0.75, 
                      width = 0.25, height = 0.25,
                      just = c("left", "bottom"))
pushViewport(sample_vp)
grid.draw(roundrectGrob())
grid.draw(boxplot)
popViewport()

sample_vp2 <- viewport(x = 0.5, y = 0.5, 
                      width = 0.5, height = 0.5,
                      just = c("right", "top"))
pushViewport(sample_vp2)
grid.draw(roundrectGrob())
grid.draw(boxplot)
popViewport()

# vp_nested
grid.draw(rectGrob())

sample_vp <- viewport(x = 0.5, y = 0.5, 
                      width = 0.5, height = 0.5,
                      just = c("left", "bottom"))
# coordinates on the scale of the bigger viewport
sample_vp2 <- viewport(x = 0.1, y = 0.1, 
                       width = 0.4, height = 0.4,
                       just = c("left", "bottom"))

pushViewport(sample_vp)
grid.draw(roundrectGrob(gp = gpar(fill = "darkred")))
pushViewport(sample_vp2)
grid.draw(roundrectGrob())
grid.draw(boxplot)
popViewport(2)

# coorsys_plot
ex_vp <- viewport(x = 0.5, y = 0.5, 
                  just = c("center", "center"),
                  height = 0.8, width = 0.8,
                  xscale = c(0, 100), yscale = c(0, 10))
pushViewport(ex_vp)
grid.draw(rectGrob())
grid.draw(circleGrob(x = unit(20, "native"), y = unit(5, "native"),
                     r = 0.1, gp = gpar(fill = "lightgrey")))
grid.draw(circleGrob(x = unit(85, "native"), y = unit(8, "native"),
                     r = 0.1, gp = gpar(fill = "darkred")))
popViewport()

# scatter_table
wrldcp_tbl <- worldcup %>%
  filter(Team %in% c("Germany", "Spain", "Netherlands", "Uruguay")) %>%
  group_by(Team) %>%
  dplyr::summarize(`Average time` = round(mean(Time), 1),
                   `Average shots` = round(mean(Shots), 1), 
                   .groups = "drop") %>%
  tableGrob()

grid.draw(ggplotGrob(time_vs_shots)) #transform scatterplot into grob
wrldcp_tbl_vp <- viewport(x = 0.22, y = 0.85, 
                          just = c("left", "top"),
                          height = 0.1, width = 0.2)
pushViewport(wrldcp_tbl_vp)
grid.draw(wrldcp_tbl)
popViewport()