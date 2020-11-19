//
//  SleepCycleView.swift
//  Learning1
//
//  Created by Bharath Patil on 12/11/20.
//

import Foundation
import UIKit

class SleepCycleView : UIView
{
    let pi=CGFloat.pi
    let margin=CGFloat(0.2)
    let lineWidth=CGFloat(40)
    let roundingRadius=CGFloat(40)
    var topRectY,bottomRectY,leftRectX,rightRectX: CGFloat!;
    var verticeArray : [CGPoint] = []
    var angleArray : [CGFloat] = []
    var pc : CGPoint!;
    var periodArray:[Period]=[]

    func minutesToAngle(_ min:Int) -> CGFloat
    {
        return ((CGFloat.pi/2)+CGFloat(1440-min)*2*CGFloat.pi/1440)
    }
    
    func isBetweenAngles(startAngle:CGFloat, endAngle:CGFloat, testAngle:CGFloat) -> Bool
    {
        let p1=CGPoint(x:cos(startAngle),y:sin(startAngle))
        let p2=CGPoint(x:cos(endAngle),y:sin(endAngle))
        let p=CGPoint(x:cos(testAngle),y:sin(testAngle))
        let cp1 = p1.x * p.y - p.x * p1.y
        let cp2 = p2.x * p.y - p.x * p2.y
        let d = (p1.x + p2.x)*p.x + (p1.y+p2.y)*p.y
        return ((cp1*cp2 < 0) && (d>0))
    }
    
    func straightSectionIntersection(p1:CGPoint, p2:CGPoint, angle:CGFloat) -> CGPoint
    {
        if(abs(p1.x-p2.x)<0.1)//vertical line
        {
            let m = tan(angle)//using y=mx+c. Hence calculate tan
            let y = m*(p1.x-pc.x)+pc.y
            return CGPoint(x:p1.x,y:y)
        }
        else //horizontal line.
        {
            let m = tan(CGFloat.pi/2-angle)//using x=my+c. Hence calculate cot=tan(pi/2-theta).
            let x = m*(p1.y-pc.y)+pc.x
            return CGPoint(x:x,y:p1.y)
        }
    }
    
    func curvedSectionIntersection(p:CGPoint, angle:CGFloat) -> CGFloat
    {
        let r = roundingRadius
        let m = tan(angle)
        let a = 1 + m*m
        let cx = p.x-pc.x
        let cy = p.y-pc.y
        let b = -2*(cx+m*cy)
        let c = cx*cx + cy*cy - r*r
        
        var D = b*b-4*a*c;
        if (D<0)
        {
            D=0
        }
        let x1 = (-b-sqrt(D))/(2*a)
        let x2 = (-b+sqrt(D))/(2*a)
        
        var fx:CGFloat!
        var fy:CGFloat!
        //print("x1=\(x1),x2=\(x2)")
        if((x1*x1)<(x2*x2)) //choose the farther intersection point
        {
            fx=(x2-cx);
        }
        else
        {
            fx=(x1-cx);
        }
        var ySquare=r*r-fx*fx;
        if(ySquare<0)
        {
            ySquare=0;
        }
        if(cy<0)
        {
            fy=(-1)*sqrt(ySquare)
        }
        else
        {
            fy=sqrt(ySquare)
        }
        //print("fx=\(fx),fy=\(fy)")
        return atan2(fy,fx)
    }
    
    func drawAnglePart(context : CGContext, section: Int, startAngle : CGFloat, endAngle : CGFloat)
    {
        if(section%2==0) //Straight section
        {
            let p1=straightSectionIntersection(p1: verticeArray[section],
                                               p2: verticeArray[(section+1)%verticeArray.count], angle: startAngle)
            let p2=straightSectionIntersection(p1: verticeArray[section],
                                               p2: verticeArray[(section+1)%verticeArray.count], angle: endAngle)
            context.beginPath()
            context.addLines(between: [p1,p2])
            context.strokePath()
        }
        else //curved section
        {
            var x,y:CGFloat!
            let p1 = verticeArray[section]
            let p2 = verticeArray[(section+1)%verticeArray.count]
            let distx1=(p1.x-pc.x)*(p1.x-pc.x)
            let distx2=(p2.x-pc.x)*(p2.x-pc.x)
            if(distx1<distx2)
            {
                x=p1.x
            }
            else
            {
                x=p2.x
            }
            let disty1=(p1.y-pc.y)*(p1.y-pc.y)
            let disty2=(p2.y-pc.y)*(p2.y-pc.y)
            if(disty1<disty2)
            {
                y=p1.y
            }
            else
            {
                y=p2.y
            }
            let arcCenter=CGPoint(x:x,y:y)
            let a1=curvedSectionIntersection(p:arcCenter,
                                             angle: startAngle)
            let a2=curvedSectionIntersection(p:arcCenter,
                                             angle: endAngle)
            //print("arc angle1 = \(a1*180/CGFloat.pi), angle2 = \(a2*180/CGFloat.pi)")
            //print("startAngle = \(startAngle*180/CGFloat.pi), endAngle = \(endAngle*180/CGFloat.pi)")

            context.beginPath()
            context.addArc(center: arcCenter,
                           radius: roundingRadius,
                           startAngle: a1,
                           endAngle: a2,
                           clockwise: false)
            context.strokePath()
        }
    }
    
    func drawAnglePeriod(context : CGContext, startAngle : CGFloat, endAngle : CGFloat)
    {
        var indexStart,indexEnd:Int!;
        var sa=startAngle
        var ea=endAngle
        
        if(sa>CGFloat.pi)
        {
            sa-=2*CGFloat.pi
        }
        if(ea>CGFloat.pi)
        {
            ea-=2*CGFloat.pi
        }
        for i in 0...angleArray.count-1
        {
            let j=(i+1)%angleArray.count
            //print(angleArray[i],startAngle,endAngle)
            if(isBetweenAngles(startAngle: angleArray[i],
                                endAngle: angleArray[j],
                                testAngle: sa))
            {
                indexStart=i;
            }
            if(isBetweenAngles(startAngle: angleArray[i],
                                endAngle: angleArray[j],
                                testAngle: ea))
            {
                indexEnd=i;
            }
        }
        //print("IndexStart=\(indexStart),IndexEnd=\(indexEnd)")
        var a1=sa
        var a2=ea
        while(true)
        {
            let nextIndex=(indexStart+1)%(angleArray.count)
            if(indexStart==indexEnd)
            {
                a2=ea
            }
            else
            {
                a2=angleArray[nextIndex]

            }
            //print("Drawing Index : \(indexStart)")
            //print("startAngle = \(a1*180/CGFloat.pi), endAngle = \(a2*180/CGFloat.pi)")
            drawAnglePart(context:context,
                          section:indexStart,
                          startAngle:a1,
                          endAngle:a2)
            if(indexStart==indexEnd)
            {
                break
            }
            indexStart=nextIndex;
            a1=angleArray[nextIndex]
        }
    }
    
    func drawBackground(context : CGContext)
    {
        topRectY=bounds.height*(1-margin)
        bottomRectY=bounds.height*margin
        leftRectX=bounds.width*margin
        rightRectX=bounds.width*(1-margin)
        let corners=[CGPoint(x:leftRectX,y:topRectY),
                     CGPoint(x:leftRectX,y:bottomRectY),
                     CGPoint(x:rightRectX,y:bottomRectY),
                     CGPoint(x:rightRectX,y:topRectY)
                    ]
        
        pc=CGPoint(
                x:(leftRectX+rightRectX)/2,
                y:(topRectY+bottomRectY)/2)

        context.setLineWidth(lineWidth)
        verticeArray.removeAll()
        angleArray.removeAll()
        for i in 0...(corners.count-1)
        {
            context.beginPath()
            var start = corners[i]
            var end = corners[(i+1)%(corners.count)]
            var varyX:Bool
            var sign:Int
            
            varyX=abs(start.x-end.x)>0.1
            if(varyX)
            {
                sign=(Int(start.x) - Int(pc.x)).signum()
                start.x -= roundingRadius*CGFloat(sign)
                sign=(Int(end.x) - Int(pc.x)).signum()
                end.x -= roundingRadius*CGFloat(sign)
            }
            else
            {
                sign=(Int(start.y) - Int(pc.y)).signum()
                start.y -= roundingRadius*CGFloat(sign)
                sign=(Int(end.y) - Int(pc.y)).signum()
                end.y -= roundingRadius*CGFloat(sign)
            }
            verticeArray.append(CGPoint(x : start.x, y : start.y))
            verticeArray.append(CGPoint(x : end.x, y : end.y))
            
            angleArray.append(atan2(start.y-pc.y,start.x-pc.x))
            angleArray.append(atan2(end.y-pc.y,end.x-pc.x))
            
            context.addLines(between: [start,end])
            context.strokePath()
            
            context.beginPath()

            var angle,startAngle,endAngle,signX,signY,cx,cy:CGFloat
            signX=CGFloat((Int(start.x)-Int(pc.x)).signum())
            signY=CGFloat((Int(start.y)-Int(pc.y)).signum())
            
            angle=atan2(signY,signX)
            
            startAngle=angle-CGFloat.pi/4
            endAngle=angle+CGFloat.pi/4
            
            cx=corners[i].x-roundingRadius*signX;
            cy=corners[i].y-roundingRadius*signY;
            
            context.addArc(center: CGPoint(x:cx,y:cy),
                           radius: roundingRadius,
                           startAngle: startAngle,
                           endAngle: endAngle,
                           clockwise: false)
            context.strokePath()
        }
        //print("angleArrayCount=\(angleArray.count)")
    }
    
    override func draw(_ rect: CGRect)
    {
        var startAngle:CGFloat!
        var endAngle:CGFloat!
        if let context = UIGraphicsGetCurrentContext()
        {
            //always call background draw first.
            //It calculates some important stuff that the rest use.
            context.setStrokeColor(UIColor.gray.cgColor)
            drawBackground(context: context)
            
            context.setStrokeColor(UIColor.black.cgColor)
            for period in periodArray
            {
                startAngle=minutesToAngle(period.getEndMinute())
                endAngle=minutesToAngle(period.getStartMinute())
                //print("Period : \(startAngle*180/CGFloat.pi), \(endAngle*180/CGFloat.pi)")
                drawAnglePeriod(context: context,
                                startAngle:startAngle,
                                endAngle:endAngle)
            }
        }
    }
    
    func update(periodArray : [Period])
    {
        self.periodArray=periodArray;
        setNeedsDisplay()
    }
}
