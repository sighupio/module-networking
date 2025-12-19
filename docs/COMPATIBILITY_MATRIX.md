# Compatibility Matrix

| Module Version / Kubernetes Version | 1.24.X             | 1.25.X             | 1.26.X             | 1.27.X             | 1.28.X             | 1.29.X             | 1.30.X             | 1.31.X             | 1.32.X                   | 1.33.X             | 1.34.X             |
| ----------------------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------------ | ------------------ | ------------------ |
| v1.10.0                             | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |                          |                    |                    |
| v1.11.0                             | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                          |                    |                    |
| v1.12.0                             | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                          |                    |                    |
| v1.12.1                             | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                          |                    |                    |
| v1.12.2                             | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                          |                    |                    |
| v1.14.0                             | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                          |                    |                    |
| v1.15.0                             |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                          |                    |                    |
| v1.16.0                             |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                          |                    |                    |
| v1.17.0                             |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                          |                    |                    |
| v2.0.0                              |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                          |                    |                    |
| v2.1.0                              |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning: (tech preview) |                    |                    |
| v2.2.0                              |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark:       |                    |                    |
| v3.0.0                              |                    |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark:       | :white_check_mark: | :white_check_mark: |
| v3.1.0                              |                    |                    |                    |                    |                    |                    |                    |                    | :white_check_mark:       | :white_check_mark: | :white_check_mark: |

:white_check_mark: Compatible

:warning: Has issues

:x: Incompatible

## Warning

- :x: module version `v1.7.0` has a known bug with calico on Kubernetes >= 1.21. Please do not use.
- :x: module version `v1.8.0` has a known bug breaking upgrades and with calico on Kubernetes >= 1.21. Please do not use.
- :x: module version `v1.8.1` has a known bug breaking upgrades and with calico on Kubernetes >= 1.21. Please do not use.
- :x: module version `v1.8.2` has a known bug with calico on Kubernetes >= 1.21. Please do not use.
- :x: module version `v1.9.0`is not compatible with Kubernetes <= 1.20.
- :warning: calico in module version v2.1.0 is not officially compatible with Kubernetes 1.32

## Legacy versions

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |       1.17.X       |       1.18.X       |       1.19.X       |       1.20.X       |       1.21.X       |       1.22.X       | 1.23.X             |
| ----------------------------------- | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | ------------------ |
| v1.0.0                              |     :warning:      |     :warning:      |     :warning:      |                    |                    |                    |                    |                    |                    |                    |
| v1.0.1                              |     :warning:      |     :warning:      |     :warning:      |                    |                    |                    |                    |                    |                    |                    |
| v1.1.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| v1.2.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| v1.2.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| v1.3.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |
| v1.4.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |                    |                    |
| v1.5.0                              |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |                    |
| v1.6.0                              |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |
| v1.7.0                              |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |                    |
| v1.8.0                              |                    |                    |                    |                    |                    |                    |        :x:         |        :x:         |        :x:         | :x:                |
| v1.8.1                              |                    |                    |                    |                    |                    |                    |        :x:         |        :x:         |        :x:         | :x:                |
| v1.8.2                              |                    |                    |                    |                    |                    |                    | :white_check_mark: |        :x:         |        :x:         | :x:                |
| v1.9.0                              |                    |                    |                    |                    |                    |                    |        :x:         | :white_check_mark: | :white_check_mark: | :white_check_mark: |
