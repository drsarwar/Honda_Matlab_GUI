# Honda_Matlab_GUI

In case of both codes the COM port needs to be set first.
It is easy to find it from the arduino IDE by going to tool and then port.
Then the COM port needs to be edited in the Matlab code accordingly.

### Full_GUI_pepperoni

This GUI shows all the peripheral pressure pads along with the proximity, central pressure and Shear X and Shear Y.

The line that has the comment "%different ylim for proximity" needs to be edited depending on the baseline value for the proximity which can be different for different sensors

### Prox_pressure_shear_pepperoni

This GUI only shows the proximity, central pressure and shear
The shear is represented as a magnitude and angle.

The line that has the comment "%different ylim for proximity" needs to be edited depending on the baseline value for the proximity which can be different for different sensors
