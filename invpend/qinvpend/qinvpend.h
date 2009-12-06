#ifndef QINVPEND_H
#define QINVPEND_H

#include <QWidget>
#include <QPainter>
#include <NaInvPnd.h>

class QinvPend : public QWidget
{
    Q_OBJECT

public:
    QinvPend(QWidget* parent);

    void    drawCart(QPainter& painter);
    void    drawForce(QPainter& painter);
    void    drawScale(QPainter& painter);

    void    paintEvent(QPaintEvent*);
    void    mousePressEvent(QMouseEvent* event);

public slots:
    void    setState(double x, double phi);
    void    setForce(double f);
    void    repaint();
    void    nextState();

private:
    /** State of the inverted pendulum on the cart */
    double  m_fX, m_fPhi;
    /** Force applied to the inverted pendulum */
    double  m_fForce;

    double  m_fForceStep;

    /* Inverted pendulum on the cart itself */
    NaInvPend   m_InvPend;
};

#endif // QINVPEND_H
