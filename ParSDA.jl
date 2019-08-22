import DataFrames
using Gtk.ShortNames
using Gtk
using Plots, LaTeXStrings
using CSV
pyplot(dpi=80)

# Create window
win = Window()
# Position of win [3 == center]
set_gtk_property!(win, :title,"PSD Analizer 1.0")
set_gtk_property!(win, :window_position,3)
#set_gtk_property!(win, :height_request,300)
set_gtk_property!(win, :accept_focus,true)

################################################################################
# Menu settings for file
menu1 = MenuItem("_File")
filemenu1 = Menu(menu1)
new = MenuItem("New")
push!(filemenu1, new)
open = MenuItem("Open")
push!(filemenu1, open)
save = MenuItem("Save")
push!(filemenu1, save)
push!(filemenu1, SeparatorMenuItem())
exit = MenuItem("Exit")
idnew = signal_connect(exit, :activate) do widget
  destroy(win)
end
push!(filemenu1, exit)
mb = MenuBar()
push!(mb, menu1)

# Menu setting for edit
menu2 = MenuItem("_Edit")
filemenu2 = Menu(menu2)
clearmenu = MenuItem("Clear")
idnew = signal_connect(clearmenu, :activate) do widget
  set_gtk_property!(setFactor, :label, "Set")
  set_gtk_property!(factor, :sensitive, true)
  set_gtk_property!(factor, :text, "conversion factor")

  set_gtk_property!(setNumFiles, :label, "Set")
  set_gtk_property!(numFiles, :sensitive, true)
  set_gtk_property!(numFiles, :text,"# of databases")
end
push!(filemenu2, clearmenu)
push!(mb, menu2)

# Menu setting for help
menu3 = MenuItem("_Help")
filemenu3 = Menu(menu3)
help = MenuItem("Help...")
push!(filemenu3, help)

about = MenuItem("About...")
idnew = signal_connect(about, :activate) do widget
  win3 = Window()
  gabout = Grid()
  push!(win3, gabout)
  set_gtk_property!(gabout, :column_spacing, 10)
  set_gtk_property!(gabout, :row_spacing, 10)
  set_gtk_property!(gabout, :margin_bottom, 10)
  set_gtk_property!(gabout, :margin_top, 30)
  set_gtk_property!(gabout, :column_homogeneous,true)
  # Position of win [3 == center]
  set_gtk_property!(win3, :title,"About")
  set_gtk_property!(win3, :window_position,3)
  set_gtk_property!(win3, :width_request,390)

  okabout = Button("Ok")
  signal_connect(okabout, :clicked) do widget
    destroy(win3)
  end
  label = Label("Hola")
  GAccessor.markup(label,"""<b>PhD Kelvyn B. Sánchez Sánchez</b><i>\nInstituto Tecnológico de Celaya</i>\nkelvyn.baruc@gmail.com\n
  <b>PhD Eusebio Bolanos Reynoso</b>\n<i>Instituto Tecnológico de Orizaba</i>\neusebio.itorizaba@gmail.com""")
  GAccessor.justify(label,Gtk.GConstants.GtkJustification.CENTER)
  gabout[1:3,1] = label
  gabout[2,2] = okabout

  showall(win3)
end
push!(filemenu3, about)
push!(mb, menu3)

################################################################################
# General grid
g = Grid()
set_gtk_property!(g, :column_spacing, 10)
set_gtk_property!(g, :row_spacing, 10)
set_gtk_property!(g, :margin_bottom, 10)
set_gtk_property!(g, :margin_left, 10)
set_gtk_property!(g, :margin_right, 10)
#set_gtk_property!(g, :column_homogeneous, true)

g[1:3,1] = mb

################################################################################
# Frame for app
load = Frame("Load Data")
set_gtk_property!(load, :width_request,300)
set_gtk_property!(load, :height_request,400)
set_gtk_property!(load, :label_xalign, 0.50)

gload = Grid()
gscroll = Grid()
scrollwin = ScrolledWindow(gscroll)
set_gtk_property!(gload, :margin_top,10)
set_gtk_property!(gload, :margin_bottom,10)
set_gtk_property!(gload, :margin_left,10)
set_gtk_property!(gload, :margin_right,10)
set_gtk_property!(gload, :column_spacing, 10)
set_gtk_property!(gload, :row_spacing, 10)

# Table for data
datalist = ListStore(String, Int, Bool)

# Visual table
dataview = TreeView(TreeModel(datalist))
set_gtk_property!(dataview, :width_request, 280)
set_gtk_property!(dataview, :reorderable, true)

# Set selectable
selmodel = G_.selection(dataview)
set_gtk_property!(dataview, :width_request,280)
set_gtk_property!(dataview, :height_request,380)

# Define type of cell
rTxt = CellRendererText()
rTog = CellRendererToggle()

# Define the source of data
c1 = TreeViewColumn("Label", rTxt, Dict([("text",0)]))
c2 = TreeViewColumn("Data", rTxt, Dict([("text",1)]))
c3 = TreeViewColumn("Status", rTog, Dict([("active",2)]))

# Allows to select rows
for c in [c1, c2, c3]
  GAccessor.resizable(c, true)
end
set_gtk_property!(dataview, :enable_grid_lines, 3)
set_gtk_property!(dataview, :expand, true)

push!(dataview, c1, c2, c3)

gscroll[1,1] = dataview
gload[1:3,1] = scrollwin

# Defining bottons to manipulate the table
del = Button("Delete")

signal_connect(del, "clicked") do widget
  if hasselection(selmodel)
    global currentIt
    currentIt = selected(selmodel)
    index = Gtk.index_from_iter(datalist, currentIt)
    deleteat!(datalist, currentIt)
    DataFrames.deletecols!(datadiam,index)
  end
end

cleardata = Button("Clear")

signal_connect(cleardata, "clicked") do widget
  while length(datalist) > 0
    deleteat!(datalist,1)
    DataFrames.deletecols!(datadiam,1)
  end
end

add = Button("Add")
datadiam = DataFrames.DataFrame()
signal_connect(add, "clicked") do widget
  # Create window
  win2 = Window()
  # Position of win [3 == center]
  set_gtk_property!(win2, :title,"Add data")
  set_gtk_property!(win2, :window_position,3)
  set_gtk_property!(win2, :height_request,190)
  #set_gtk_property!(win2, :height_request,200)
  #set_gtk_property!(win2, :accept_focus,true)
  loadframe = Frame()

  gadd = Grid()
  set_gtk_property!(gadd, :margin_top,50)
  set_gtk_property!(gadd, :margin_left,10)
  set_gtk_property!(gadd, :margin_right,10)
  #set_gtk_property!(gadd, :column_homogeneous, true)
  set_gtk_property!(gadd, :column_spacing, 10)
  set_gtk_property!(gadd, :row_spacing, 10)

  labeldata = Entry()
  set_gtk_property!(labeldata, :tooltip_markup, "Enter the label")
  set_gtk_property!(labeldata, :width_request, 200)
  set_gtk_property!(labeldata, :text,"label")

  canceldata = Button("Cancel")
  signal_connect(canceldata, :clicked) do widget
    destroy(win2)
  end

  browsedata = Button("Browse")
  signal_connect(browsedata, :clicked) do widget
    global dlg
    dlg = open_dialog("Choose file...", win2, ("*.txt, *.csv",), select_multiple=false)
  end

  addtodata = Button("Add")
  signal_connect(addtodata, :clicked) do widget
    global dlg
    global datadiam
    label1 = get_gtk_property(labeldata, :text, String)
    data = CSV.read(dlg, datarow=1)
    datadiam[Symbol(label1)] = data[1]
    # save to global data
    ll = size(datadiam[Symbol(label1)],1)
    status = datadiam[Symbol(label1)] != String
    push!(datalist,(label1,ll,status))
    destroy(win2)
  end

  gadd2 = Grid()
  set_gtk_property!(gadd2, :column_spacing, 10)


  gadd[1:2,1] = gadd2
  gadd2[1,1] = labeldata
  gadd2[2,1] = browsedata
  gadd[1,2] = canceldata
  gadd[2,2] = addtodata

  push!(loadframe,gadd)
  push!(win2,loadframe)
  showall(win2)
end

gload[1,3] = del
gload[2,3] = cleardata
gload[3,3] = add
push!(load,gload)

################################################################################
setting = Frame("Setting Analysis")
set_gtk_property!(setting, :width_request,300)
set_gtk_property!(setting, :height_request,400)
set_gtk_property!(setting, :label_xalign, 0.50)

gsetting = Grid()
set_gtk_property!(gsetting, :margin_top,10)
set_gtk_property!(gsetting, :margin_bottom,10)
set_gtk_property!(gsetting, :margin_left,10)
set_gtk_property!(gsetting, :margin_right,10)
set_gtk_property!(gsetting, :column_spacing, 10)
set_gtk_property!(gsetting, :column_homogeneous, true)
set_gtk_property!(gsetting, :row_spacing, 30)

factor = Entry()
set_gtk_property!(factor, :tooltip_markup, "Enter the conversion factor")
set_gtk_property!(factor, :width_request, 100)

setFactor = Button("Set")
set_gtk_property!(setFactor, :width_request, 30)
set_gtk_property!(setFactor, :xalign, 0.50)
idnew = signal_connect(setFactor, :clicked) do widget
  msgFactor = get_gtk_property(factor, :text, String)

  # Check for non a number
  try
    global numFactor
    numFactor = parse(Float64,msgFactor)

    # Check for number > 0
    try
      if numFactor ≤ 0
        lolol
      end
      set_gtk_property!(setFactor, :label, "Set ✔")
      set_gtk_property!(factor, :sensitive, false)
    catch
      warn_dialog("Oops!... Factor must be higher than 0", win)
    end
  catch
    warn_dialog("Oops!... Please write a number", win)
  end
end
signal_connect(win, "key-press-event") do widget, event
  if event.keyval == 65293
    msgFactor = get_gtk_property(factor, :text, String)
    # Check for non a number
    try
      global numFactor
      numFactor = parse(Float64,msgFactor)

      # Check for number > 0
      try
        if numFactor ≤ 0
          lolol
        end
        set_gtk_property!(setFactor, :label, "Set ✔")
        set_gtk_property!(factor, :sensitive, false)
      catch
        warn_dialog("Oops!... Factor must be higher than 0", win)
      end
    catch
      warn_dialog("Oops!... Please write a number", win)
    end
  end
end


distr = Frame()
choices = ["% Number", "% Length", "% Surface", "% Volume"]
f = Gtk.GtkBox(:v)
r = Vector{RadioButton}(undef, 4)
r[1] = RadioButton(choices[1])
push!(f,r[1])
r[2] = RadioButton(r[1],choices[2])
push!(f,r[2])
r[3] = RadioButton(r[2],choices[3])
push!(f,r[3])
r[4] = RadioButton(r[3],choices[4])
push!(f,r[4])
push!(distr,f)

labeldistr = Label("Select distribution:")
labelfactor = Label("Enter the conversion factor:")

gfactor = Grid()
set_gtk_property!(gfactor, :column_spacing, 10)
set_gtk_property!(gfactor, :row_spacing, 10)


over = Frame()
gover = Grid()
set_gtk_property!(gover, :margin_top,6)
set_gtk_property!(gover, :margin_bottom,6)
set_gtk_property!(gover, :margin_left,6)
set_gtk_property!(gover, :margin_right,6)
set_gtk_property!(gover, :column_homogeneous, true)
oversize = CheckButton("Oversize")
undersize = CheckButton("Undersize")
set_gtk_property!(oversize,:active,false)
set_gtk_property!(undersize,:active,false)
gover[1,1] = oversize
gover[2,1] = undersize
push!(over, gover)


gfactor[1:2,1] = labelfactor
gfactor[1,2] = factor
gfactor[2,2] = setFactor
gsetting[1:2,1] = gfactor
gsetting[1,3] = labeldistr
gsetting[2,3] = distr
gsetting[1:2,4] = over
push!(setting,gsetting)

###############################################################################
# Results Section
plots = Frame("Results & Plots")
set_gtk_property!(plots, :width_request,300)
set_gtk_property!(plots, :height_request,400)
set_gtk_property!(plots, :label_xalign, 0.50)

gplot = Grid()
set_gtk_property!(gplot, :column_spacing, 10)  # introduce a 15-pixel gap between columns
set_gtk_property!(gplot, :row_spacing, 10)  # introduce a 15-pixel gap between columns
set_gtk_property!(gplot, :column_homogeneous, true)

set_gtk_property!(gplot, :margin_top,10)
set_gtk_property!(gplot, :margin_bottom,10)
set_gtk_property!(gplot, :margin_left,10)
set_gtk_property!(gplot, :margin_right,10)

gtkimg = Image()
set_gtk_property!(gtkimg, :width_request,250)
set_gtk_property!(gtkimg, :height_request,200)
set_gtk_property!(gtkimg, :xpad,10)
set_gtk_property!(gtkimg, :ypad,10)
#push!(frameimg, gtkimg)
gplot[1:3,2] = gtkimg

exit = Button("Clear")
clear = Button("Drawn")
run = Button("Export")
gplot[1,3] = exit
gplot[2,3] = clear
gplot[3,3] = run

push!(plots, gplot)


###############################################################################

g[1,2] = load
g[2,2] = setting
g[3,2] = plots

################################################################################
# Main bottons
exit = Button("Exit")
#set_gtk_property!(exit, :width_request, 300)
idnew = signal_connect(exit, :clicked) do widget
  destroy(win)
end

clear = Button("Clear")
#set_gtk_property!(clear, :width_request, 300)
idnew = signal_connect(clear, :clicked) do widget
  set_gtk_property!(setFactor, :label, "Set")
  set_gtk_property!(factor, :sensitive, true)
  set_gtk_property!(factor, :text, "")
  while length(datalist) > 0
    deleteat!(datalist,1)
    DataFrames.deletecols!(datadiam,1)
  end
  DataFrames.deletecols!(datadiam, :)
  empty!(gtkimg)
end

run = Button("Run")
idnew = signal_connect(run, :clicked) do widget
  empty!(gtkimg)
  function px2dtc(diam; factor = 0.4355)
    diameter = sqrt.(diam) / factor
    num = zeros(length(diameter),1)
    den = zeros(length(diameter),1)

    sum_num_D = 0
    sum_den_D = 0
    sum_num_S = 0
    sum_den_S = 0

    DTC = zeros(4,2)
    for m = 1:4
      # Cálculo de D[m,m-1]
      sum_num = 0
      sum_den = 0

      for i = 1:length(diameter)
        sum_num = diameter[i]^m + sum_num
      end

      for i = 1:length(diameter)
        sum_den = diameter[i]^(m-1) + sum_den
      end

      # Se guarda el valor del diametro
      DTC[m,1] = sum_num / sum_den

      # Cálculo de S[m,m-1]
      sum_num = 0
      sum_den = 0

      for i = 1:length(diameter)
        sum_num = (diameter[i]^(m-1) * (diameter[i] - DTC[m,1])^2) + sum_num
      end

      for i = 1:length(diameter)
        sum_den = diameter[i]^(m-1) + sum_den
      end

      # Se guarda el valor de la desviación
      DTC[m,2] = sqrt(sum_num / sum_den)

    end
    return DTC
  end

  global numFactor
  global datadiam
  global PSD
  PSD = []
  for i=1:size(datadiam,2)
    psd = px2dtc(datadiam[i], factor = numFactor)
    push!(PSD,psd)
  end

  global PSDTotal

  PSDTotal = []
  for j=1:size(datadiam,2)
    PSDInd = zeros(4,2)
    for i=1:4
      # Solve for lognorm parameters
      x0 = 6 # Initial value for D43
      y0 = 0.6 # Initial value for S43
      e = 1 # Error
      while e > 0.0001
        df1x = exp(x0+0.5*y0^2)
        df1y = y0*exp(x0+0.5*y0^2)
        df2x = 2.0*exp(2*x0+y0^2)*(exp(y0^2)-1.0)
        df2y = 2*y0*exp(2*x0+y0^2)*(exp(y0^2)-1)+2*exp(2.0*x0+y0^2)*y0*exp(y0^2)
        f1 = exp(x0+0.5*y0^2) - PSD[j][i,1]
        f2 = (exp(2*x0+y0^2))*(exp(y0^2)-1.0)- PSD[j][i,2]
        A = [df1x df1y; df2x df2y]
        b = [-f1; -f2]
        hj = A\b
        x1 = x0 + hj[1]
        y1 = y0 + hj[2]
        e = ((x1-x0)^2+(y1-y0)^2)^0.5
        x0 = x1
        y0 = y1

      end
      PSDInd[i,1] = x0
      PSDInd[i,2] = y0
    end
    push!(PSDTotal, PSDInd)
  end

  function lognorm(mean, sd; x = 0:1.04:1000)
    fd = zeros(length(x), 1)

    for i=1:length(x)
      fd[i, 1] = (1/(sd*sqrt(2*pi)))*exp(-((log(x[i]))-mean)^2/(2*sd^2))
    end

    density = (fd.*100)./sum(fd);
    return x, density
  end

  plt = []
  set_gtk_property!(gtkimg, :file, "")

  global choicedistr
  choisedistr = []
  for i=1:4
    if get_gtk_property(r[i], :active, Bool) == true
      global choicedistr
      choicedistr = i
    end
  end

  global y, x
  x = []
  y = []
  for i=1:length(datalist)
    global y, x, yy
    x, yy = lognorm(PSDTotal[i][choicedistr,1], PSDTotal[i][choicedistr,2], x = 0:10:1000)
    push!(y,yy)

    plt = plot!(x,y[i], label = datalist[i,1], lw=1.5,
    xlabel = "Size (μm)", ylabel=choices[choicedistr],
    xtickfont=font(12),ytickfont=font(12),guidefont=font(12), legendfontsize=10,
    framestyle=:box, xlim=(0,maximum(x)),ylim=(0,100))

    if length(datalist) == 1
      #################################################################
      # Initialization for vectors
      global y_under, y_over, yy
      y_under = zeros(length(yy),1)
      y_over = zeros(length(yy),1)
      y_under[1,1] = yy[1,1]
      y_over[1,1] = 100 - y_under[1,1]

      #################################################################
      # Oversize & Undersize calculation
      for l = 2:length(yy)
        # Undersize
        y_under[l,1] = y_under[l-1,1] + yy[l]
        # Oversize
        y_over[l,1] = 100 - y_under[l,1]
      end
      overs = get_gtk_property(oversize,:active,Bool)
      unders = get_gtk_property(undersize,:active,Bool)

      if overs == true
        plot!(x,y_over,ls=:dash, lw=1.5, label = "Oversize")
      end

      if unders == true
        plot!(x,y_under,ls=:dot, lw=1.5, label = "Undersize")
      end
    end
  end

  savefig(plt,"PSD.png")
  set_gtk_property!(gtkimg, :file, "PSD.png")
  rm("PSD.png")

end
#set_gtk_property!(run, :width_request, 300)
g[1,3] = exit
g[2,3] = clear
g[3,3] = run

#g[1:3,3] = g2
push!(win,g)
showall(win)
