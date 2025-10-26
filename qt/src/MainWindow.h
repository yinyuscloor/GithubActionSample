#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTimer>
#include <QPaintEvent>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget * parent = nullptr);
    ~MainWindow();

protected:
    auto paintEvent(QPaintEvent * e) -> void override;
    
    
private:
    Ui::MainWindow * ui {};
    QTimer * timer {};
};

#endif // MAINWINDOW_H