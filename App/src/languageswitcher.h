#ifndef LANGUAGESWITCHER_H
#define LANGUAGESWITCHER_H

#include <QObject>
#include <QDebug>
#include <QLibraryInfo>
#include <QTextCodec>
#include <QTranslator>
#include <QApplication>

class LanguageSwitcher : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString languageSwitch READ getLanguageSwitch NOTIFY languageChanged)
    Q_PROPERTY(QString ls READ getLanguageSwitch NOTIFY languageChanged)
    Q_PROPERTY(QString update READ getLanguageSwitch NOTIFY languageChanged)
    Q_PROPERTY(QString switched READ getLanguageSwitch NOTIFY languageChanged)
public:
    explicit LanguageSwitcher(QObject *parent = 0);

    QString getLanguageSwitch();

    Q_INVOKABLE bool selectLanguage(QString language);

signals:
    void languageChanged();

public slots:

private:
    QTranslator *_translator;
    bool _loaded;
};

#endif // LANGUAGESWITCHER_H
