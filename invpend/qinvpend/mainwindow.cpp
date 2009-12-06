#include <QTimer>
#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent),
      m_qInvPend(NULL), m_qTimer(NULL),
      ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    m_qInvPend = new QinvPend(this);
    setCentralWidget(m_qInvPend);

    m_qTimer = new QTimer(this);
    connect(m_qTimer, SIGNAL(timeout()), m_qInvPend, SLOT(nextState()));
    m_qTimer->start(1000);
}

MainWindow::~MainWindow()
{
    delete ui;
}
