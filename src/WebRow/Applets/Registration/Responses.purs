module WebRow.Applets.Registration.Responses where

import WebRow.Applets.Auth.Types (Password)
import WebRow.Applets.Registration.Forms (FormLayout)
import WebRow.Applets.Registration.Types (Namespace)
import WebRow.Mailer (Email)
import WebRow.Routing (FullUrl)

data ConfirmationResponse
  = ConfirmationSucceeded Email Password
  | InvalidEmailSignature
  | InitialPasswordForm FormLayout
  | EmailRegisteredInbetween Email
  | PasswordValidationFailed FormLayout

data RegisterEmailResponse
  = EmailSent Email FullUrl
  | EmailValidationFailed FormLayout
  | InitialEmailForm FormLayout

data ChangeEmailResponse
  = ChangeEmailInitialForm FormLayout

data Response
  = ConfirmationResponse ConfirmationResponse
  | RegisterEmailResponse RegisterEmailResponse
  | ChangeEmailResponse ChangeEmailResponse

type ResponseRow responses
  = Namespace Response responses
