# I m installing linkding with persistent storage ( To know about What persistent storage is, check out my Kubernetes 101 post )

# YAML for Persistent Volume ( pv.yml )
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 8Gi
  hostPath:
    path: /home/user/data
  storageClassName: development
---

# YAML for Persistent Volume Claim ( pvc.yml )

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: development
---

# YAML for Linkding Container Deployment  ( Install Linkding With Persistent Storage )
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: linkding
  labels:
    application: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      application: frontend
  template:
    metadata:
      labels:
        application: frontend
    spec:
      containers:
      - name: linkding
        image: sissbruecker/linkding
        ports:
        - containerPort: 9090
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - name: data
          mountPath: /etc/linkding/data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: data
---

--------------------------------------------------------------------------------------
## Create Deployments
$ kubectl apply -f ./pv.yml
$ kubectl apply -f ./pvc.yml
$ kubectl apply -f ./linkding.yml

# Apply Deployments
$ kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
linkding   1/1      1            1          102s

# Expose to the local network
$ microk8s kubectl expose deployment linkding --type=NodePort

# Get the Port
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
linkding     NodePort    10.152.183.77   <none>        9090:31071/TCP   30s

# Access the Linkding Bookmark Manager ( http://10.0.1.86:31071 )

--------------------------------------------------------------------------------------
# To create username password for Linkding ( Go to Portainer -> Application -> Linkding -> Console Access
# python manage.py createsuperuser --username=user --email=admin@example.com
# user = user
# password = you set in above command
