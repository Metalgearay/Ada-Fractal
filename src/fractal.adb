with Ada.Text_IO;
with Glfw.Windows;
with Glfw.Windows.Context;
with GL.Buffers;
with GL.Types.Colors;
with Glfw.Input;
with Glfw.Input.Keys;
with GL.Fixed.Matrix;
with GL.Immediate;
with GL.Types;
with Ada.Containers.Vectors;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
procedure fractal is

   procedure Render is
        use Ada.Text_IO;
        Back_Colour : constant GL.Types.Colors.Color := (0.0, 0.0, 0.0, 1.0);
        begin
            GL.Buffers.Set_Color_Clear_Value (Back_Colour);
            GL.Buffers.Clear ((True, False, False, True));
        exception
            when others =>
                 Put_Line ("An exception occurred in Render.");
            raise;
    end Render;

use Glfw.Input;
use GL.Fixed.Matrix;
use GL.Types;
use GL.Types.Doubles;
use Ada.Numerics.Elementary_Functions;
use Ada.Text_IO;

type point is record
    X: Float;
    Y: Float;
end record;

package Point_Vector is new Ada.Containers.Vectors(Natural, point);

points : Point_Vector.Vector;
Window1 :  aliased Glfw.Windows.Window;
Running : Boolean := True;
Title : constant String := "Test";
Length : Float := Sqrt((800.0*800.0/16.0)+(600.0+600.0/16.0));

begin
    Glfw.Init;
    Window1.Init(800,600,Title); 
    Glfw.Windows.Context.Make_Current(Window1'Access); 
    Projection.Apply_Orthogonal(0.0, 800.0, 600.0, 0.0, -1.0, 1.0);
    while Running loop 
        Render;
        GL.Immediate.Set_Color((0.0, 0.0, 1.0, 1.0));
        declare 
            Token : GL.Immediate.Input_Token := GL.Immediate.Start(Lines);
            pointToAdd : point;
        begin
            pointToAdd := (800.0/4.0, 600.0/2.0);
            points.Append(pointToAdd);
            pointToAdd := (800.0/2.0, 600.0/4.0);
            points.Append(pointToAdd);
            pointToAdd := ((800.0*3.0)/4.0, 600.0/2.0);
            points.Append(pointToAdd);
            for i in Integer range 1..5 loop
                length := length/Sqrt(2.0);
                declare 
                    dummyPt : point;
                    newPoints : Point_Vector.Vector;
                    x1: Float;
                    y1 : Float;
                    theta : Float;
                    angle: Float;
                    rx: Float;
                    ry: Float;
                    test: Float;
                begin
                    for I in points.First_Index..points.Last_Index-1 loop
                        x1 := points.element(I).X;
                        y1 := points.element(I).Y;
                        theta := Arctan(points.element(I+1).Y-y1, points.element(I+1).X-x1);
                        test := (points.element(I+1).X-x1)**2+(points.element(I+1).Y-y1)**2;
                        length := Sqrt(test)/Sqrt(2.0);
                        if I mod 2 = 0 then
                            angle :=  Ada.Numerics.Pi/4.0;
                        else
                            angle := -(Ada.Numerics.Pi/4.0);
                        end if;
                        rx := x1 + length*cos(theta+angle);
                        ry := y1 + length*sin(theta+angle);
                        newPoints.Append(points.element(I));
                        dummyPt := (rx, ry);
                        newPoints.Append(dummyPt);
                    end loop;
                    newPoints.Append(points.element(points.Last_Index-1));
                    points := newPoints;
                end;
            end loop;
            Put_Line(points.element(points.First_Index).X'Img);
            Token.Add_Vertex(Vector2'(Double(points.element(points.First_Index).X), 
            Double(points.element(points.First_Index).Y)));
            for I in points.First_Index+1..points.Last_Index-1 loop
                Token.Add_Vertex(Vector2'(Double(points.element(I).X), 
                Double(points.element(I).Y)));
            end loop;
            Token.Add_Vertex(Vector2'(Double(points.element(points.Last_Index-1).X), 
            Double(points.element(points.Last_Index-1).Y)));
        end;
        Glfw.Windows.Context.Swap_Buffers(Window1'Access);
        Glfw.Input.Poll_Events;
        Running := Running and not 
        (Window1.Key_State (Glfw.Input.Keys.Escape) = Glfw.Input.Pressed);
            Running := Running and not Window1.Should_Close;
    end loop;
end fractal;