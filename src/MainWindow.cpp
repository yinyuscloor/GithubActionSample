#include "MainWindow.h"
#include "ui_MainWindow.h"

#include <QLabel>
#include <QDebug>
#include <QSpinBox>
#include <QString>
#include <QTimer>
#include <QPixmap>
#include <QPushButton>
#include <QPainter>
#include <QListWidget>
#include <QListWidgetItem>


MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow), timer {new QTimer(this)} {
    ui->setupUi(this);

    connect(ui->pushButton, &QPushButton::clicked, this, [this](bool checked){
        this->timer->start(100);

        qDebug() << "Hello world!\n";
    });
    connect(this->timer, &QTimer::timeout, this, [this]{
        static bool direction {true};

        this->ui->progressBar->setValue(
            ui->progressBar->value() + (direction ? 1 : -1)
        );

        direction = 
        ui->progressBar->value() == 0 
        ? true : ui->progressBar->value() == 100 
        ? false : direction;
    });

    QLabel(nullptr).setPixmap(QPixmap().scaled(QSize(100, 100), Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation));

    // todo: todolist codes
    connect(ui->addBtn, &QPushButton::clicked, this, [this](bool checked){
        if (ui->lineEdit->text().isEmpty()) {
            return;
        }

        auto todoListItem {new QListWidgetItem(ui->dateTimeEdit->dateTime().toString() + QStringLiteral(" ") + ui->lineEdit->text(), ui->todoList)};

        ui->lineEdit->clear();

        todoListItem->setCheckState(Qt::CheckState::Unchecked);
    });

    connect(ui->delBtn, &QPushButton::clicked, this, [this](bool checked){      
        for (auto selectItem : ui->todoList->selectedItems()) {
            delete ui->todoList->takeItem(ui->todoList->row(selectItem));
        }
    });

}

MainWindow::~MainWindow() { delete ui; }

auto MainWindow::paintEvent(QPaintEvent * e) -> void {
    QPainter pter(this);

    pter.setPen(Qt::red);
    pter.drawLine(0, 0, 100, 100);
    pter.drawEllipse(0, 0, 100, 100);
}