| OWASP Item | Description | Example | When | Solution |
| Injection | Anyone who can send untrusted data to the system. Often found in SQL, noSQL, LDAP, XPath, XML parses, SMTP headers, Expression language, ORM queries | Data inputed by user is not validate, filtered or sanitized | string query=" SELECT* FROM accounts where ID={request.Parameters[RequestParameter.ID]}". Usage of vulnerable frameworks or library | Apply Static source (SAST) or Dynamic application test (DAST) into CI/CD pipeline. Use safe API, avoid interpreters, parameterize ex: query WHERE id=?. Escape special characters. Use *limit* in command query |
| Broken Authentication | Attacker has access to hundreds of username, password using automated brute force, dictionary attack tools. | use a list of well-known passwords: 123456, admin/admin. Use pw as a sole factor and with strict password policy encouraging users to use and reuse weak passwords. Session timeout are not set | Uses plain text or weakly hashed passwords. Miss 2FA, Exposes session IDs in the URL, not validate session periodly. ||