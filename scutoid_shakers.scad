INCH = 25.4;
H = 4*INCH;
W = INCH / 16;
L = INCH;

R6 = L;
R5 = L/2/sin(360/5/2);

A5 = -360/5;
rotate5 =
[[ cos(A5), sin(A5), 0]
,[-sin(A5), cos(A5), 0]
,[       0,       0, 1]];

A6 = -360/6;
rotate6 =
[[ cos(A6), sin(A6), 0]
,[-sin(A6), cos(A6), 0]
,[       0,       0, 1]];

//hexagon corners
H2 =						[  0, R6,-H/2];
H3 =					rotate6*[  0, R6,-H/2];
H4 =				rotate6*rotate6*[  0, R6,-H/2];
H5 =			rotate6*rotate6*rotate6*[  0, R6,-H/2];
H6 =		rotate6*rotate6*rotate6*rotate6*[  0, R6,-H/2];
H1 =	rotate6*rotate6*rotate6*rotate6*rotate6*[  0, R6,-H/2];
H0 = H6;

//pentagon corners
P1_x = H1.x - H1.y*(cos(90+A6)-cos(90+A5/2))/(sin(90+A5/2)-sin(90+A6));
delta= R5 - P1_x;	//unalign pentagon center from hexagon center
P5 =		rotate5*rotate5*rotate5*rotate5*[ R5,  0, H/2] - [delta,0,0];
P4 =			rotate5*rotate5*rotate5*[ R5,  0, H/2] - [delta,0,0];
P3 =				rotate5*rotate5*[ R5,  0, H/2] - [delta,0,0];
P2 =					rotate5*[ R5,  0, H/2] - [delta,0,0];
P1 =						[ R5,  0, H/2] - [delta,0,0];

//equator/middle corners
alpha = (-A6-A5)/2;
beta = 2*alpha - 90;
M5 = (P5 + H5)/2;
M4 = (P4 + H4)/2;
M3 = (P3 + H3)/2;
M2 = (P2 + H2)/2;
M1 = [M2.x + (L/2 + L*cos(alpha))/tan(beta), 0, 0];
M6 = M1;
M0 = M1;

module	shaker()
{
	//top,bottom
	translate([-delta,0,0])
	translate([0,0,H/2])
	cylinder(r=R5,$fn=5,h=W,center=true);

	rotate([0,0,90])
	translate([0,0,-H/2])
	cylinder(r=R6,$fn=6,h=W,center=true);

	//interior surface points
	m1 = M1 - [W,0,0];
	h1 = H1 - [W,0,0];
	h0 = H0 - [W,0,0];

	hull()	//triangle
	{
		polyhedron([m1,h1,h0],[[0,1,2]]);
		polyhedron([M1,H1,H0],[[0,1,2]]);
	}

	h3 = [W+H3.x,H3.y,H3.z];
	h4 = [W+H4.x,H4.y,H4.z];

	p3 = [W+P3.x,P3.y,P3.z];
	p4 = [W+P4.x,P4.y,P4.z];

	hull()	//flat panel
	{
		polyhedron([P3,P4,p4,p3],[[0,1,2,3]]);
		polyhedron([H3,H4,h4,h3],[[0,1,2,3]]);
	}

	Slices = 40;
	//transition between pentagon side and hexagon side keeping length L
	multmatrix(	//shear
	[[1,0,(P4.x-H4.x)/H,0]
	,[0,1,0,0]
	,[0,0,1,0]
	,[0,0,0,1]])
	translate([M4.x,M4.y,-H/2])
	rotate([0,0,A6/2])
	linear_extrude(H,slices=Slices*2,twist=-12)
	square([L,W]);

	mirror([0,1,0])
	multmatrix(	//shear
	[[1,0,(P4.x-H4.x)/H,0]
	,[0,1,0,0]
	,[0,0,1,0]
	,[0,0,0,1]])
	translate([M4.x,M4.y,-H/2])
	rotate([0,0,A6/2])
	linear_extrude(H,slices=Slices*2,twist=-12)
	square([L,W]);

    module	panel(P1,P2,M1,M2)
    {
	for(	K1 = [1:Slices])
	let(	K0 = K1 - 1
	,	k0 = K0/Slices
	,	k1 = K1/Slices
	,	A0 = (P1 - M1)*k0 + M1
	,	A1 = (P1 - M1)*k1 + M1
	,	B0 = (P2 - M2)*k0 + M2
	,	B1 = (P2 - M2)*k1 + M2
	,	xA0 = cross(A1-A0,B0-A0)
	,	xA1 = cross(B1-A1,A0-A1)
	,	xB0 = cross(A0-B0,B1-B0)
	,	xB1 = cross(B0-B1,A1-B1)
	,	a0 = A0 + W * xA0 / norm(xA0)
	,	a1 = A1 + W * xA1 / norm(xA1)
	,	b0 = B0 + W * xB0 / norm(xB0)
	,	b1 = B1 + W * xB1 / norm(xB1)
	)	
	hull()
	{
		polyhedron([A0,a0,b0,B0],[[0,1,2,3]]);
		polyhedron([A1,a1,b1,B1],[[0,1,2,3]]);
	}
    }

	difference()
	{
		panel(P1,P2,M1,M2);
		mirror([0,1,0])	translate([0,0,-H/2])	cube([M1.x,W,H]);
	}
	mirror([0,1,0])
	difference()
	{
		panel(P1,P2,M1,M2);
		mirror([0,1,0])	translate([0,0,-H/2])	cube([M1.x,W,H]);
	}

	difference()
	{
		panel(M1,M2,H1,H2);
		mirror([0,1,0])	mirror([0,0,1])	translate([0,0,-H/2])	cube([M1.x,W,H]);
	}
	mirror([0,1,0])
	difference()
	{
		panel(M1,M2,H1,H2);
		mirror([0,1,0])	mirror([0,0,1])	translate([0,0,-H/2])	cube([M1.x,W,H]);
	}
//	This pair of scutoid_shakers is licensed under
//	MIT License
//
//	Copyright (c) 2024 DrT0M
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
}

module	salt()
{
	difference()
	{
		shaker();
		//hole
		translate([-delta,0,0])
		translate([0,0,H/2])
		cylinder(r=L/16,h=W*2,$fn=16,center=true);
	}
}

module	pepper()
{
	mirror([0,0,1])
	difference()
	{
		shaker();
		//holes
		for(k=[-A6:-A6:360])
		rotate([0,0,k])	
		translate([L/2,0,-H/2])
		cylinder(r=L/25.4,h=W*2,$fn=16,center=true);
	}
}

//put side by side
mirror([1,0,0])
{
	translate([-1,1,0])
	rotate([0,0,-(90+A5)-(90+A6)])
	translate([-M1.x,0,0])
	color("Gainsboro")
	salt();

	translate([1,1,0])
	rotate([0,0,(90+A5)+(90+A6)])
	mirror([1,0,0])
	translate([-M1.x,0,0])
	color("Gray")
	pepper();
}
