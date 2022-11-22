# TP1

## Méthode n°1

**Le but va être de casser le grub**

On se rend dans le dossier boot
```
> cd ../../boot
```

Ensuite on supprime le fichier de config du grub qui se trouve dans le dossier grub2
```
> sudo rm grub2/grub.cfg
```

Bravo t'as cassé ton grub

## Méthode n°2

**Le but va être de recasser le grub**

On se rend dans le dossier loader dans le dossier boot
```
> cd ../../boot/loader
```

Ensuite on supprime les fichiers de config qui se trouve dans le dossier entries
```
> sudo rm -r entries/
```

Bravo t'as cassé ton grub d'une autre façon

## Méthode n°3

**Le but est d'empêcher l'initialisation de l'OS**

On se rend dans le dossier boot
```
> cd ../../boot
```

Ensuite on supprime les fichiers avec un nom qui commence par **init**
```
> sudo rm init*
```
Bravo t'as encore cassé l'OS

## Méthode n°4

**Le but est de recasser le grub**

On se rend dans le dossier boot
```
> cd ../../boot
```

Ensuite on va supprimer le dossier grub2
```
> sudo rm -r grub2
```
Bravo t'as encore cassé le grub

## Méthode n°5

**Le but est de tout supprimer**

On se rend dans le racine
```
> cd ../..
```

Ensuite on va supprimer le dossier grub2
```
> sudo rm *
```
Bravo t'as tout cassé

## Méthode n°6

**Le but est de casser les utilisateurs**

On va modifier les permissions du fichier shadow qui se trouve dans le dossier etc
```
> sudo chmod 776 ../../etc/shadow
```

Ensuite on va modifier le fichier shadow
```
> sudo nano ../../etc/shadow
```
Et ducoup on va modifier la ligne de l'utilisateur en rajoutant des caractères au mot de passe et on va faire pareil pour l'utilisateur root histoire de bien tout péter

Bravo t'as cassé les utilisateurs

![CPT](./pics/cpt.gif)