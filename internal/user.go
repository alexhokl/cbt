package internal

// contextKeyUser is the context key under which the authentication
// interceptors place the authenticated user identifier. It is an unexported
// struct type so no other package can collide with it or read it by accident.
type contextKeyUser struct{}
