
# Prepare strings

From project root:
python ./sbin/translation.py ./App/assets/scenes/scenes.json
mv ./Extra.qml ./App/translations/

# Translation flow

Developer from App directory:
lupdate App.pro -ts translations/*.ts

Translator:
linguist translations/DeadAscend_*.ts

Developer from App directory:
lrelease translations/*.ts

# Flags
https://github.com/hjnilsson/country-flags
