#include "languageswitcher.h"

LanguageSwitcher::LanguageSwitcher(QObject *parent) : QObject(parent)
{
    _loaded = false;
    _translator = new QTranslator(this);

    qDebug() << this << "::LanguageSwitcher try use system language" << QLocale::system().language() << "translations";
    _loaded = _translator->load(QLocale(), "DeadAscend","_",":/translations");
    if(_loaded) {
        QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
        qApp->installTranslator(_translator);
        qDebug() << this << "::LanguageSwitcher initialized and loaded" << QLocale::system().language();
    } else
        qDebug() << this << "::LanguageSwitcher using default translations";

}

QString LanguageSwitcher::getLanguageSwitch()
{
    return "";
}

bool LanguageSwitcher::selectLanguage(QString language)
{
    if(language == QString("es")) {
        _loaded = _translator->load("DeadAscend_"+language, ":/translations");
        if(_loaded) {
            QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
            qApp->installTranslator(_translator);
            qDebug() << this << "::selectLanguage loaded" << language;
            emit languageChanged();
        }
    } else if(language == QString("da")) {
        _loaded = _translator->load("DeadAscend_"+language, ":/translations");
        if(_loaded) {
            QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
            qApp->installTranslator(_translator);
            qDebug() << this << "::selectLanguage loaded" << language;
            emit languageChanged();
        }
    } else if(language == QString("de")) {
        _loaded = _translator->load("DeadAscend_"+language, ":/translations");
        if(_loaded) {
            QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
            qApp->installTranslator(_translator);
            qDebug() << this << "::selectLanguage loaded" << language;
            emit languageChanged();
        }
    } else if(language == QString("nl")) {
        _loaded = _translator->load("DeadAscend_"+language, ":/translations");
        if(_loaded) {
            QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));
            qApp->installTranslator(_translator);
            qDebug() << this << "::selectLanguage loaded" << language;
            emit languageChanged();
        }
    } else {
        if(_loaded) {
            qApp->removeTranslator(_translator);
            _loaded = false;
            qDebug() << this << "::selectLanguage no translations found for" << language << "setting default";
            emit languageChanged();
        }
    }

    return _loaded;
}
