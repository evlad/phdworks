#include <math.h>
#include <QPen>
#include <QBrush>
#include <QMouseEvent>

#include "qinvpend.h"

QinvPend::QinvPend(QWidget* parent)
    : QWidget(parent), m_fX(0.0), m_fPhi(0.0), m_fForce(0.0),
      m_fForceStep(0.002),
      m_InvPend(0.5, 0.2, 0.1, 0.3, 0.006)
{
    m_InvPend.Reset();
}


void
QinvPend::drawCart(QPainter& painter)
{
    QRect   cart(QPoint(width()/2 - 80, height() - 80), QSize(160, 35));
    QPoint  weel1(QPoint(width()/2 - 60, height() - 45));
    QPoint  weel2(QPoint(width()/2 + 60, height() - 45));

    painter.setPen(QPen(Qt::black));
    painter.fillRect(cart, Qt::Dense4Pattern);
    painter.drawRect(cart);
    painter.setPen(QPen(Qt::darkRed, 4));
    painter.drawEllipse(weel1, 10, 10);
    painter.drawEllipse(weel2, 10, 10);

    int     x0 = width()/2;
    int     y0 = height() - 80;
    int     L = height() - 70;
    painter.drawLine(QPoint(x0, y0),
                     QPoint(x0 + L * sin(m_fPhi),
                            y0 - L * cos(m_fPhi)));
}


void
QinvPend::drawForce(QPainter& painter)
{
    if(fabs(m_fForce) < 1e-5) {
        return;
    }
    int         nLen = (int)(5 * m_fForce / m_fForceStep);
    int		iSize = 8;
    QPoint      p(width()/2 - 80, height() - 58);
    if(m_fForce < 0) {
        iSize *= -1;
        p.setX(width()/2 + 80);
    }
    QPolygon    poly;
    printf("p.x() - iSize - nLen=%d: %d %d %d\n",
           p.x() - iSize - nLen, p.x(), iSize, nLen);
    fflush(stdout);
    poly.setPoints(7,
                   p.x(), p.y(),
                   p.x() - iSize, p.y() + iSize,
                   p.x() - iSize, p.y() + iSize/2,
                   p.x() - iSize - nLen, p.y()  + iSize/2,
                   p.x() - iSize - nLen, p.y() - iSize/2,
                   p.x() - iSize, p.y() - iSize/2,
                   p.x() - iSize, p.y() - iSize);
    painter.setPen(QPen(Qt::black, 1));
    painter.setBrush(QBrush(Qt::red));
    painter.drawPolygon(poly);
    painter.setPen(QPen(Qt::darkRed));
    painter.drawText(p.x() - 3*iSize, p.y() - 2*abs(iSize), QString("%1").arg(m_fForce));
}


void
QinvPend::drawScale(QPainter& painter)
{
    painter.setPen(QPen(Qt::black));
    painter.drawLine(0, height() - 30, width(), height() - 30);
    painter.drawLine(width()/2, height() - 30, width()/2, height() - 25);
    painter.drawText(width()/2, height() - 15, QString("%1").arg(m_fX));
    painter.setPen(QPen(Qt::blue));
    painter.drawText(width()/2, height() - 1, QString("%1").arg(m_fPhi*180/M_PI));
}


void
QinvPend::setState(double x, double phi)
{
    if(phi != m_fPhi || x != m_fX) {
        m_fX = x;
        m_fPhi = phi;
        //repaint();
    }
}


void
QinvPend::setForce(double f)
{
    if(f != m_fForce) {
        m_fForce = f;
        //repaint();
    }
}


void
QinvPend::repaint()
{
    QPainter    painter;
    painter.begin(this);
    //painter.fillRect(rect(), Qt::white);
    painter.eraseRect(rect());
    drawCart(painter);
    drawForce(painter);
    drawScale(painter);
    painter.end();
}


void
QinvPend::nextState()
{
    NaReal  y[2];
    NaReal  u = -m_fForce;
    m_InvPend.Function(&u, y);
    printf("F=%g: (%g %g) => (%g %g)\n", u, m_fX, m_fPhi, y[0], y[1]);
    fflush(stdout);
    m_fX = y[0];
    m_fPhi = y[1];
    m_fForce = 0.0;

    update();
}


void
QinvPend::paintEvent(QPaintEvent*)
{
    repaint();
}


void
QinvPend::mousePressEvent(QMouseEvent* event)
{
    switch(event->button()) {
        case Qt::LeftButton:
            if(m_fForce > 0)
                m_fForce = 0.0;
            else
                m_fForce -= m_fForceStep;
            break;
        case Qt::RightButton:
            if(m_fForce < 0)
                m_fForce = 0.0;
            else
                m_fForce += m_fForceStep;
            break;
        default:
            return;
        }
    update();
}
