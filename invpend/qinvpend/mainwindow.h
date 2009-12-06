#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QMainWindow>
#include "qinvpend.h"

namespace Ui
{
    class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();

    QinvPend    *m_qInvPend;
    QTimer      *m_qTimer;
private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
