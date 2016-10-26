#include "fpstext.h"

FPSText::FPSText(QQuickItem *parent): QQuickPaintedItem(parent), _currentFPS(0), _cacheCount(0)
{
    _times.clear();
    setFlag(QQuickItem::ItemHasContents);
}

FPSText::~FPSText()
{
}

void FPSText::recalculateFPS()
{
    qint64 currentTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    _times.push_back(currentTime);

    while (_times[0] < currentTime - 1000) {
        _times.pop_front();
    }

    int currentCount = _times.length();
    _currentFPS = (currentCount + _cacheCount) / 2;
    //qDebug() << _currentFPS;

    if (currentCount != _cacheCount) fpsChanged(_currentFPS);

    _cacheCount = currentCount;
}

int FPSText::fps()const
{
    return _currentFPS;
}

void FPSText::paint(QPainter *painter)
{
    recalculateFPS();
    //qDebug() << __FUNCTION__;
    QBrush brush(Qt::yellow);

    painter->setBrush(brush);
    painter->setPen(Qt::NoPen);
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawRoundedRect(0, 0, boundingRect().width(), boundingRect().height(), 0, 0);
    update();
}

